resource "cloudflare_record" "validation_record_acm_certificate_assets" {

  for_each = { for opt in local.acm_assets_domain_validation_options : opt.resource_record_name => opt }

  depends_on = [
    aws_acm_certificate.assets
  ]

  zone_id = var.cloudflare_zone_id

  name  = each.value.resource_record_name
  type  = each.value.resource_record_type
  value = trimsuffix(each.value.resource_record_value, ".")

}

resource "aws_acm_certificate_validation" "validation_record_acm_certificate_assets" {
  provider        = aws.us-east-1
  count           = length(var.domain_names) == 0 ? 0 : 1
  certificate_arn = aws_acm_certificate.assets[0].arn
  validation_record_fqdns = [
    for validation_option in aws_acm_certificate.assets[0].domain_validation_options :
    trimsuffix(validation_option.resource_record_name, ".")
  ]
}

resource "cloudflare_record" "cloudflare_domain" {

  for_each = toset(var.domain_vendor == "cloudflare" && length(var.domain_names) != 0 ? var.domain_names : [])
  zone_id  = var.cloudflare_zone_id

  name    = each.value
  type    = "CNAME"
  value   = aws_cloudfront_distribution.server.domain_name
  ttl     = var.cloudflare_ttl
  proxied = var.cloudflare_proxied

  depends_on = [
    aws_cloudfront_distribution.server
  ]

}