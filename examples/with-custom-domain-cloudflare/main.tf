module "static-website" {
  source = "../../"

  name = "hello.ashari.me"

  custom_domain_provider = "CLOUDFLARE"
  custom_domain_records  = ["hello", "www.hello"]
  custom_domain_zone_id  = "abcdefghijklmnopqrstuvwxyz12345"

  cloudflare_api_token = "AaaA11AaaaAaaA1aa11AAa11A76aaAAa9aAAaa-a"

}
