output "s3_bucket" {
  value = aws_s3_bucket.assets.bucket
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.server.domain_name
}