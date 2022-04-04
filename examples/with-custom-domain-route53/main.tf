module "static-website" {
  source = "../../"

  name = "hello.ashari.tech"

  custom_domain_provider = "ROUTE53"
  custom_domain_records  = ["test", "www.test"]
  custom_domain_zone_id  = var.custom_domain_zone_id

}
