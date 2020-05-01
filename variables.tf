variable "name" {
  type        = string
  description = "Name of your website/application"
}

variable "is_versioning_enabled" {
  type        = bool
  default     = false
  description = "Toggle to enable or disable S3 bucket versioning"
}

variable "is_include_codebuild" {
  type        = bool
  default     = false
  description = "Toggle to enable or disable codebuild integration to github"
}

variable "resource_tags" {
  default = null
}

variable "codebuild_environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  default     = []
  description = ""
}

variable "github_token" {
  type        = string
  default     = ""
  description = "Github token that have get repo permission and manage webhook permission"
}

variable "github_name" {
  type        = string
  default     = ""
  description = "Github name that store source code of website/application format \"{username}/{reponame}\""
}

variable "github_branch" {
  type        = string
  default     = "master"
  description = "Github branch to be deployed"
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

variable "artifact_bucket" {
  type    = string
  default = "-"
}