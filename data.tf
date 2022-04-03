data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# START: Custom Domain using CLOUDFLARE
data "cloudflare_zone" "this" {
  count   = var.custom_domain_provider == "CLOUDFLARE" ? 1 : 0
  zone_id = var.custom_domain_zone_id
}
# END: Custom Domain using CLOUDFLARE
