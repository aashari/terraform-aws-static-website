module "static-website" {
  source                               = "../../"
  name                                 = "ashari.tech"
  cloudfront_access_log_bucket         = "default-cloudfront-access-logs-ap-southeast-1-560170365667"
  cloudfront_access_log_enable_cookies = true
}
