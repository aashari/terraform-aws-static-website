variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API token"
}

variable "custom_domain_zone_id" {
  type        = string
  description = "Domain Provider zone ID which custom domain is registered to"
}
