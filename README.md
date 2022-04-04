# AWS Static Website Terraform module

This is a Terraform module to provision a static website using AWS S3 and CloudFront with optional custom domain ability

## Usage

### Without Custom Domain
```
module "static-website" {
  source = "git@github.com:aashari/terraform-aws-static-website.git"
  name   = "test.ashari.me"
}
```
The code above will provide an S3 bucket and a Cloudfront Distribution serving static assets in an S3 bucket

### With Custom Domain Cloudflare
```
module "static-website" {
  source = "git@github.com:aashari/terraform-aws-static-website.git"

  name = "hello.ashari.me"

  custom_domain_provider = "CLOUDFLARE"
  custom_domain_records  = ["hello", "www.hello"]
  custom_domain_zone_id  = "abcdefghijklmnopqrstuvwxyz12345"

  cloudflare_api_token = "AaaA11AaaaAaaA1aa11AAa11A76aaAAa9aAAaa-a"

}
```
The code above will provide an S3 bucket and Cloudfront Distribution serving static assets in an S3 bucket with additional ACM certificates for the custom domains assigned to Cloudfront and creating new records in the Cloudflare Zone

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.8.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.8.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.1.2 |
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the static website stacks.<br />For example: `my-website`, `my-website-staging`, `ashari.com`, `andi.ashari.me` | `string` | `""` | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_default_root_object"></a> [default\_root\_object](#input\_default\_root\_object) | Default root object to serve | `string` | `index.html` | no |
| <a name="input_default_not_found_page"></a> [default\_not\_found\_page](#input\_default\_not\_found\_page) | Default not found page | `string` | `index.html` | no |
| <a name="input_custom_domain_provider"></a> [custom\_domain\_provider](#input\_custom\_domain\_provider) | Custom domain provider name. <br />Available values: `CLOUDFLARE` | `string` | `""` | no |
| <a name="input_custom_domain_records"></a> [custom\_domain\_records](#input\_custom\_domain\_records) | Custom domain records name to use for CloudFront distribution.<br />For example `["hello", "www.hello"]` which represent `hello.{{ROOT_DOMAIN}}` and `www.hello.{{ROOT_DOMAIN}}`, where `ROOT_DOMAIN` is coming from domain name from Zone provided in `custom_domain_zone_id` variable  | `list(string)` | `[]` | yes if <a name="input_custom_domain_provider"></a> [custom\_domain\_provider](#input\_custom\_domain\_provider) is not empty  |
| <a name="input_custom_domain_zone_id"></a> [custom\_domain\_zone\_id](#input\_custom\_domain\_zone\_id) | Domain Provider zone ID which custom domain is registered to.<br />In Cloudflare this is called Zone Id, in Route53 this is called Hosted Zone Id  | `string` | `""` | yes if <a name="input_custom_domain_provider"></a> [custom\_domain\_provider](#input\_custom\_domain\_provider) is not empty  |
| <a name="input_cloudflare_api_token"></a> [cloudflare\_api\_token](#input\_cloudflare\_api\_token) | Cloudflare API token  | `string` | `""` | yes if <a name="input_custom_domain_provider"></a> [custom\_domain\_provider](#input\_custom\_domain\_provider) is equal to `CLOUDFLARE`  |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | S3 bucket name |
| <a name="output_cloudfront_distribution_domain_name"></a> [cloudfront\_distribution\_domain\_name](#output\_cloudfront\_distribution\_domain\_name) | CloudFront distribution domain name |

## License
Apache 2 Licensed. See [LICENSE](https://github.com/aashari/terraform-aws-static-website/tree/master/LICENSE) for full details.
