resource "cloudflare_record" "validation_record_acm_certificate_assets" {

  depends_on = [
    aws_acm_certificate.assets
  ]

  count   = var.domain_vendor == "cloudflare" && length(aws_acm_certificate.assets) == 1 ? length(var.domain_names) : 0
  zone_id = var.cloudflare_zone_id

  name  = aws_acm_certificate.assets[0].domain_validation_options[count.index].resource_record_name
  type  = aws_acm_certificate.assets[0].domain_validation_options[count.index].resource_record_type
  value = trimsuffix(aws_acm_certificate.assets[0].domain_validation_options[count.index].resource_record_value, ".")

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

  count   = var.domain_vendor == "cloudflare" && length(var.domain_names) != 0 ? length(var.domain_names) : 0
  zone_id = var.cloudflare_zone_id

  name  = var.domain_names[count.index]
  type  = "CNAME"
  value = aws_cloudfront_distribution.server.domain_name

  depends_on = [
    aws_cloudfront_distribution.server
  ]

}