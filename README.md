# AWS Static Website Terraform module

This is a Terraform module to provision a static website using AWS S3 and CloudFront.

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
| <a name="provider_cloudflare"></a> [random](#provider\_cloudflare) | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the static website stacks, for example: my-website, my-website-staging, ashari.com, andi.ashari.me | `string` |  | `true` |
| <a name="input_default_root_object"></a> [default_root_object](#input\_default\_root\_object) | Default root object to serve | `string` | `index.html` | `false` |
| <a name="input_default_not_found_page"></a> [default_not_found_page](#input\_default\_not\_found\_page) | Default not found page | `string` | `index.html` | `false` |
| <a name="input_default_tags"></a> [default_tags](#input\_default\_tags) | Default tags to apply to all resources | `map(string)` | `{}` | `false` |
| <a name="input_custom_domain_provider"></a> [custom_domain_provider](#input\_custom\_domain\_provider) | Custom domain provider name | `ENUM("CLOUDFLARE")` |  | `false` |
| <a name="input_custom_domain_records"></a> [custom_domain_records](#input\_custom\_domain\_records) | Custom domain records name to use for CloudFront distribution | `list(string)` | `[]` | `yes, if input_custom_domain_provider is filled` |
| <a name="input_custom_domain_zone_id"></a> [custom_domain_zone_id](#input\_custom\_domain\_zone\_id) | Domain Provider zone ID which custom domain is registered to | `string` |  | `yes, if input_custom_domain_provider is filled` |
| <a name="input_cloudflare_api_token"></a> [cloudflare_api_token](#input\_cloudflare\_api\_token) | CloudFlare API token | `string` |  | `yes, if input_custom_domain_provider=CLOUDFLARE` |

## Usage

### Without Custom Domain
```
module "static-website" {
  source = "git@github.com:aashari/terraform-aws-static-website.git"
  name   = "test.ashari.me"
}
```

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

## License
Apache 2 Licensed. See [LICENSE](https://github.com/aashari/terraform-aws-static-website/tree/master/LICENSE) for full details.
