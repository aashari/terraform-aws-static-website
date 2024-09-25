# AWS Static Website Terraform Module

This Terraform module provisions a static website using AWS S3 and CloudFront with optional custom domain support.

![Overview Architecture Diagram](architecture-diagram.png)

## Features

- S3 bucket for static asset storage
- CloudFront distribution for content delivery
- Optional custom domain support (Cloudflare or Route53)
- Optional CloudFront function for request manipulation
- Optional CloudFront access logging
- S3 bucket versioning

## Usage

### Basic Usage (Without Custom Domain)

```hcl
module "static_website" {
  source = "github.com/aashari/terraform-aws-static-website"
  name   = "my-static-website"
}
```

### With Custom Domain (Cloudflare)

```hcl
module "static_website" {
  source                 = "github.com/aashari/terraform-aws-static-website"
  name                   = "my-static-website"
  custom_domain_provider = "CLOUDFLARE"
  custom_domain_records  = ["@", "www"]
  custom_domain_zone_id  = "abcdefghijklmnopqrstuvwxyz12345"
  cloudflare_api_token   = "your-cloudflare-api-token"
}
```

### With Custom Domain (Route53)

```hcl
module "static_website" {
  source                 = "github.com/aashari/terraform-aws-static-website"
  name                   = "my-static-website"
  custom_domain_provider = "ROUTE53"
  custom_domain_records  = ["@", "www"]
  custom_domain_zone_id  = "Z0ABCDEFGHI1234567"
}
```

### With CloudFront Function

```hcl
module "static_website" {
  source                        = "github.com/aashari/terraform-aws-static-website"
  name                          = "my-static-website"
  cloudfront_function_file_path = "path/to/function.js"
  cloudfront_function_runtime   = "cloudfront-js-1.0"
  cloudfront_function_type      = "viewer-request"
}
```

### With CloudFront Access Logs

```hcl
module "static_website" {
  source                               = "github.com/aashari/terraform-aws-static-website"
  name                                 = "my-static-website"
  cloudfront_access_log_bucket         = "my-access-logs-bucket"
  cloudfront_access_log_enable_cookies = true
}
```

## Requirements

| Name       | Version   |
| ---------- | --------- |
| terraform  | ~> 1.9.6  |
| aws        | ~> 5.68.0 |
| random     | ~> 3.6.3  |
| cloudflare | ~> 4.0    |

## Providers

| Name       | Version   |
| ---------- | --------- |
| aws        | ~> 5.68.0 |
| random     | ~> 3.6.3  |
| cloudflare | ~> 4.0    |

## Inputs

| Name                                 | Description                                              | Type           | Default               | Required |
| ------------------------------------ | -------------------------------------------------------- | -------------- | --------------------- | :------: |
| name                                 | Name of the static website stack                         | `string`       | n/a                   |   yes    |
| default_tags                         | Default tags to apply to all resources                   | `map(string)`  | `{}`                  |    no    |
| default_root_object                  | Default root object to serve                             | `string`       | `"index.html"`        |    no    |
| default_not_found_page               | Default not found page                                   | `string`       | `"index.html"`        |    no    |
| cloudfront_access_log_bucket         | CloudFront access log bucket name                        | `string`       | `""`                  |    no    |
| cloudfront_access_log_enable_cookies | Enable CloudFront access logs to include cookies         | `bool`         | `true`                |    no    |
| cloudfront_function_file_path        | Path to the CloudFront function file                     | `string`       | `""`                  |    no    |
| cloudfront_function_runtime          | CloudFront function runtime                              | `string`       | `"cloudfront-js-1.0"` |    no    |
| cloudfront_function_type             | CloudFront function event type to trigger                | `string`       | `"viewer-request"`    |    no    |
| custom_domain_provider               | Custom domain provider name (CLOUDFLARE or ROUTE53)      | `string`       | `""`                  |    no    |
| custom_domain_records                | Custom domain records to use for CloudFront distribution | `list(string)` | `[]`                  |    no    |
| custom_domain_zone_id                | Domain Provider zone ID for the custom domain            | `string`       | `""`                  |    no    |
| custom_domain_ttl                    | Custom domain TTL                                        | `number`       | `300`                 |    no    |
| cloudflare_api_token                 | Cloudflare API token                                     | `string`       | `""`                  |    no    |
| enable_s3_versioning                 | Enable versioning on the S3 bucket                       | `bool`         | `true`                |    no    |

## Outputs

| Name                                | Description                         |
| ----------------------------------- | ----------------------------------- |
| s3_bucket_name                      | S3 bucket name                      |
| cloudfront_distribution_domain_name | CloudFront distribution domain name |

## Examples

For more detailed examples, please refer to the [examples](./examples) directory in this repository.

## Contributing

Contributions to this module are welcome! Please see the [contribution guidelines](CONTRIBUTING.md) for more information.

## License

This module is licensed under the Apache 2.0 License. See the [LICENSE](LICENSE) file for full details.

## Authors

Module created and maintained by [Andi Ashari](https://github.com/aashari).

## Support

For support, please open an issue in the GitHub repository.
