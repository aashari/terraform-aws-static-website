module "static-website" {
  source                        = "../../"
  name                          = "ashari.tech"
  custom_domain_provider        = "ROUTE53"
  custom_domain_records         = ["test", "www.test"]
  custom_domain_zone_id         = var.custom_domain_zone_id
  cloudfront_function_file_path = "function.js"
  cloudfront_function_runtime   = "cloudfront-js-1.0"
  cloudfront_function_type      = "viewer-request"
}
