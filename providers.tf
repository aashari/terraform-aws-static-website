terraform {
  required_version = "~> 1.9.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.68.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.3"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token == "" ? "AaaA11AaaaAaaA1aa11AAa11A76aaAAa9aAAaa-a" : var.cloudflare_api_token
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}
