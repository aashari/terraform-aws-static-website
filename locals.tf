locals {
  acm_assets_domain_validation_options = var.domain_vendor == "cloudflare" && length(var.domain_names) != 0 ? aws_acm_certificate.assets[0].domain_validation_options : []
  codebuild_name                       = format("%s-builder-%s", replace(var.name, ".", "-"), random_id.aws_iam_role_assets.hex)
}
