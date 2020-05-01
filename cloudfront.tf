resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "origin-access-identity/cloudfront/${aws_s3_bucket.assets.bucket_regional_domain_name}"
}

resource "aws_cloudfront_distribution" "server" {
  depends_on          = [aws_s3_bucket.assets, aws_cloudfront_origin_access_identity.origin_access_identity]
  enabled             = true
  default_root_object = "index.html"
  aliases             = var.domain_names

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    target_origin_id       = aws_s3_bucket.assets.bucket
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      headers                 = []
      query_string            = true
      query_string_cache_keys = []
      cookies {
        forward           = "none"
        whitelisted_names = []
      }
    }
  }

  origin {
    domain_name = aws_s3_bucket.assets.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.assets.bucket

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  wait_for_deployment = true

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  viewer_certificate {
    acm_certificate_arn            = length(aws_acm_certificate.assets) == 0 ? "" : aws_acm_certificate_validation.validation_record_acm_certificate_assets[0].certificate_arn
    cloudfront_default_certificate = length(aws_acm_certificate.assets) == 0 ? true : false
    ssl_support_method             = length(aws_acm_certificate.assets) == 0 ? "" : "sni-only"
  }

  tags = var.resource_tags

}

resource "aws_s3_bucket_policy" "assets" {
  depends_on = [aws_s3_bucket.assets]
  bucket     = aws_s3_bucket.assets.id
  policy = jsonencode(
    {
      Statement = [
        {
          Action = "s3:GetObject"
          Effect = "Allow"
          Principal = {
            AWS = aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
          }
          Resource = "${aws_s3_bucket.assets.arn}/*"
          Sid      = "cloudfront_get_object"
        },
        {
          Action = "s3:ListBucket"
          Effect = "Allow"
          Principal = {
            AWS = aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
          }
          Resource = aws_s3_bucket.assets.arn
          Sid      = "cloudfront_get_bucket"
        },
      ]
      Version = "2012-10-17"
    }
  )
}
