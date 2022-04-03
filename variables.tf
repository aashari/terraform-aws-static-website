variable "name" {
  type        = string
  description = "Name of the static website stacks, for example: my-website, my-website-staging, ashari.com, andi.ashari.me"
}

variable "default_tags" {
  type        = map(string)
  default     = {}
  description = "Default tags to apply to all resources"
}

variable "default_root_object" {
  type        = string
  default     = "index.html"
  description = "Default root object to serve"
}

variable "default_not_found_page" {
  type        = string
  default     = "index.html"
  description = "Default not found page"
}

variable "custom_domain_provider" {
  type        = string
  default     = ""
  description = "Custom domain provider name"
}

variable "custom_domain_records" {
  type        = list(string)
  default     = []
  description = "Custom domain records name to use for CloudFront distribution"
}

variable "custom_domain_zone_id" {
  type        = string
  default     = ""
  description = "Domain Provider zone ID which custom domain is registered to"
}

variable "cloudflare_api_token" {
  type        = string
  default     = ""
  description = "CloudFlare API token"
}
