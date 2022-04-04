module "static-website" {
  source = "../../"

  name = "ashari.tech"

  custom_domain_provider = "ROUTE53"
  custom_domain_records  = ["@", "www"]
  custom_domain_zone_id  = var.custom_domain_zone_id

}
