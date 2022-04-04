data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# START: Custom Domain using CLOUDFLARE
data "cloudflare_zone" "this" {
  count   = var.custom_domain_provider == "CLOUDFLARE" ? 1 : 0
  zone_id = var.custom_domain_zone_id
}
# END: Custom Domain using CLOUDFLARE

# START: Custom Domain using ROUTE53
data "aws_route53_zone" "this" {
  count   = var.custom_domain_provider == "ROUTE53" ? 1 : 0
  zone_id = var.custom_domain_zone_id
}
# END: Custom Domain using ROUTE53

# START: CloudFront access log bucket
data "aws_s3_bucket" "access_log" {
  count  = var.cloudfront_access_log_bucket != "" ? 1 : 0
  bucket = var.cloudfront_access_log_bucket
}
# END: CloudFront access log bucket
