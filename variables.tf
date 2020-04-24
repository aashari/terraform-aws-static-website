variable "name" {
  type        = string
  description = "Name of your website/application"
}

variable "is_versioning_enabled" {
  type        = bool
  default     = false
  description = "Toggle to enable or disable S3 bucket versioning"
}

variable "domain_names" {
  type        = list(string)
  default     = []
  description = "The list of domain names associated to cloudfront"
}

variable "domain_vendor" {
  type    = string
  default = "The name of your DNS vendor, the choice: cloudfront"
}

variable "cloudflare_api_key" {
  type        = string
  default     = "-"
  description = "Cloudflare API key"
}

variable "cloudflare_email" {
  type    = string
  default = "Cloudflare Email address"
}

variable "cloudflare_zone_id" {
  type    = string
  default = ""
}