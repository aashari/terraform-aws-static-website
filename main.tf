resource "random_string" "random-identifier" {
  length  = 6
  special = false
  upper   = false
}

locals {
  resource_name = "${replace(var.name, "/[^[:alnum:]]/", "-")}-{}-${random_string.random-identifier.result}"
  default_tags = merge({
    ManagedBy = "terraform"
  }, var.default_tags)
}

resource "aws_s3_bucket" "this" {
  bucket = "${replace(local.resource_name, "{}", "assets")}-${data.aws_region.current.id}-${data.aws_caller_identity.current.account_id}"
  tags   = local.default_tags
}

resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "origin-access-identity/cloudfront/${aws_s3_bucket.this.bucket_regional_domain_name}"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "assets" {
  bucket = aws_s3_bucket.this.id
  policy = jsonencode({
    Version = "2008-10-17",
    Statement = [
      {
        Action    = "s3:GetObject"
        Effect    = "Allow"
        Principal = { AWS = aws_cloudfront_origin_access_identity.this.iam_arn }
        Resource  = format("%s/*", aws_s3_bucket.this.arn)
        Sid       = "cloudfront_get_object"
      },
      {
        Action    = "s3:ListBucket"
        Effect    = "Allow"
        Principal = { AWS = aws_cloudfront_origin_access_identity.this.iam_arn }
        Resource  = aws_s3_bucket.this.arn
        Sid       = "cloudfront_get_bucket"
      },
    ]
  })
}

# START: Custom Domain
resource "aws_acm_certificate" "this" {

  count    = var.custom_domain_provider != "" ? 1 : 0
  provider = aws.us-east-1

  domain_name = "${var.custom_domain_records[0]}.${var.custom_domain_provider == "CLOUDFLARE" ? data.cloudflare_zone.this[0].name : data.aws_route53_zone.this[0].name}"
  subject_alternative_names = [
    for record in var.custom_domain_records : "${record}.${var.custom_domain_provider == "CLOUDFLARE" ? data.cloudflare_zone.this[0].name : data.aws_route53_zone.this[0].name}"
    if record != var.custom_domain_records[0]
  ]
  validation_method = "DNS"
  tags              = local.default_tags

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_acm_certificate_validation" "this" {
  count           = var.custom_domain_provider != "" ? 1 : 0
  provider        = aws.us-east-1
  certificate_arn = aws_acm_certificate.this[0].arn
}
# END: Custom Domain

resource "aws_cloudfront_distribution" "this" {

  depends_on = [
    aws_acm_certificate_validation.this
  ]

  enabled             = true
  default_root_object = var.default_root_object
  aliases             = var.custom_domain_provider != "" ? [for record in var.custom_domain_records : "${record}.${var.custom_domain_provider == "CLOUDFLARE" ? data.cloudflare_zone.this[0].name : data.aws_route53_zone.this[0].name}"] : []

  origin {
    domain_name = aws_s3_bucket.this.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.this.bucket
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 404
    response_code         = 200
    response_page_path    = "/${var.default_not_found_page}"
  }

  default_cache_behavior {

    compress               = true
    target_origin_id       = aws_s3_bucket.this.bucket
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      cookies { forward = "all" }
    }

  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.custom_domain_provider != "" ? false : true
    acm_certificate_arn            = var.custom_domain_provider != "" ? aws_acm_certificate.this[0].arn : null
    minimum_protocol_version       = var.custom_domain_provider != "" ? "TLSv1.2_2021" : null
    ssl_support_method             = var.custom_domain_provider != "" ? "sni-only" : null
  }

  tags = local.default_tags

}

# START: Custom Domain using CLOUDFLARE
resource "cloudflare_record" "acm" {
  depends_on = [aws_acm_certificate.this]
  count      = var.custom_domain_provider == "CLOUDFLARE" ? length(var.custom_domain_records) : 0
  zone_id    = data.cloudflare_zone.this[0].id
  name       = tolist(aws_acm_certificate.this[0].domain_validation_options)[count.index].resource_record_name
  value      = trim(tolist(aws_acm_certificate.this[0].domain_validation_options)[count.index].resource_record_value, ".")
  type       = tolist(aws_acm_certificate.this[0].domain_validation_options)[count.index].resource_record_type
  ttl        = var.custom_domain_ttl
  proxied    = false
}

resource "cloudflare_record" "this" {
  count   = var.custom_domain_provider == "CLOUDFLARE" ? length(var.custom_domain_records) : 0
  zone_id = data.cloudflare_zone.this[0].id
  name    = var.custom_domain_records[count.index]
  value   = aws_cloudfront_distribution.this.domain_name
  type    = "CNAME"
  ttl     = var.custom_domain_ttl
  proxied = false
}
# END: Custom Domain using CLOUDFLARE

# START: Custom Domain using ROUTE53
resource "aws_route53_record" "acm" {
  depends_on = [aws_acm_certificate.this]
  count      = var.custom_domain_provider == "ROUTE53" ? length(var.custom_domain_records) : 0
  zone_id    = data.aws_route53_zone.this[0].id
  name       = tolist(aws_acm_certificate.this[0].domain_validation_options)[count.index].resource_record_name
  records    = [trim(tolist(aws_acm_certificate.this[0].domain_validation_options)[count.index].resource_record_value, ".")]
  type       = tolist(aws_acm_certificate.this[0].domain_validation_options)[count.index].resource_record_type
  ttl        = var.custom_domain_ttl
}

resource "aws_route53_record" "this" {
  count   = var.custom_domain_provider == "ROUTE53" ? length(var.custom_domain_records) : 0
  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = var.custom_domain_records[count.index]
  type    = "CNAME"
  ttl     = var.custom_domain_ttl
  records = [aws_cloudfront_distribution.this.domain_name]
}
# END: Custom Domain using ROUTE53
