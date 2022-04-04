output "s3_bucket_name" {
  value = aws_s3_bucket.this.bucket
  description = "S3 bucket name"
}

output "cloudfront_distribution_domain_name" {
    value = aws_cloudfront_distribution.this.domain_name
    description = "CloudFront distribution domain name"
}
