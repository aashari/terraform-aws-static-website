# this is default provider for the entire resources
# the region will specified based on your environment setting
provider "aws" {
  version = "~> 2.9"
}

# this provider AWS with alias us-east-1 is used to create ACM certificate
# for Cloudfront which only support ACM certificate in us-east-1 region
provider "aws" {
  alias   = "us-east-1"
  version = "~> 2.9"
  region  = "us-east-1"
}

provider "random" {
  version = "~> 2.2"
}

provider "cloudflare" {
  version = "~> 2.0"
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}