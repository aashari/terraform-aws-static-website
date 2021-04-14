terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

# this is default provider for the entire resources
# the region will specified based on your environment setting
provider "aws" {
}

# this provider AWS with alias us-east-1 is used to create ACM certificate
# for Cloudfront which only support ACM certificate in us-east-1 region
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

provider "random" {
}

provider "cloudflare" {
  api_token = var.cloudflare_api_key
}
