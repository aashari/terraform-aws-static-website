module "static-website" {
  source = "../../"

  name = "hello.ashari.me"

  custom_domain_provider = "CLOUDFLARE"
  custom_domain_records  = ["hello", "www.hello"]
  custom_domain_zone_id  = var.custom_domain_zone_id

  cloudflare_api_token      = var.cloudflare_api_token

}
