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

data "aws_s3_objects" "this" {
  bucket = aws_s3_bucket.this.id
}

resource "aws_s3_object" "this" {

  count  = try(toset(data.aws_s3_objects.this.keys)[var.default_root_object] ? 0 : 1, 1)
  bucket = aws_s3_bucket.this.id
  key    = var.default_root_object

  source = "${path.module}/index.html"
  etag   = md5(file("${path.module}/index.html"))
  tags   = local.default_tags

  content_type = "text/html"

  lifecycle {
    ignore_changes = [
      source, tags, etag, metadata, content_type
    ]
  }

}

resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "origin-access-identity/cloudfront/${aws_s3_bucket.this.bucket_regional_domain_name}"
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

resource "aws_cloudfront_distribution" "this" {

  enabled             = true
  default_root_object = var.default_root_object

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
    cloudfront_default_certificate = true
  }

  tags = local.default_tags

}
