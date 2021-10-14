# Terraform AWS Static Website

This is a Terraform module to provision static website or assets using AWS S3 Bucket and AWS CloudFront, this module also support Cloudflare DNS and using AWS ACM Certificate for SSL connection for custom DNS

Why using AWS S3 Bucket + AWS CloudFront to host your static website or assets? the short answer is because it is highly available and managed by AWS also the pricing schema for this stack is very-very cheap and near to $0 per month if you have a low amount of traffic per month

## Resources 

This Terraform module will create below resources:

* S3 bucket to store your website assets 
* Cloudfront to serve your website/assets with CDN concept
* [optional] ACM certificate if you have a custom domain
* [optional] Cloudflare DNS records if you have a custom domain
* [optional] AWS CodeBuild if you enable Github integration

> Notes!
> For custom domain, it will automatically create ACM certificate, and the certificate validation will validate by using DNS validation and this module will automatically validating the domain for you, so, all you need is only to provide the cloudflare api key

## Dependencies

* Terraform: ~> 0.12
* Terraform provider: random ~> 2.2
* Terraform provider: cloudflare ~> 2.0
* Terraform provider: aws ~> 2.9

## Input Variables

| Variable Name         | Data Type    | Is Required                            | Default Value | Description                                                                                              |
|-----------------------|--------------|----------------------------------------|---------------|----------------------------------------------------------------------------------------------------------|
| name                  | string       | true                                   |               | The name of your website/assets, e.g. `andi.xyz`, `aashari.id`, `mywebsite`, or `andi-cms`               |
| is_versioning_enabled | bool         | false                                  | false         | Toggle to enable or disable S3 bucket versioning                                                         |
| domain_names          | list(string) | false                                  | []            | The list of domain names associated to cloudfront, e.g. ["www.andi.xyz","andi.xyz"], or ["cms.andi.xyz"] |
| domain_vendor         | string       | true if `domain_names` != []           |               | The name of your DNS vendor, the choice: cloudflare                                                      |
| cloudflare_api_key    | string       | true if `domain_vendor` = `cloudflare` |               | Cloudflare API key, you can get this from your Cloudflare account setting                                |
| cloudflare_zone_id    | string       | true if `domain_vendor` = `cloudflare` |               | Cloudflare zone id for `domain_names`, you can get this from zone setting                                |
| is_include_codebuild  | bool         | false                                  | false         | Toggle to enable or disable Github integration with AWS CodeBuild                                        |
| github_token          | string       | true if `is_include_codebuild` = true  |               | Github token that have get repo permission and manage webhook permission                                 |
| github_name           | string       | true if `is_include_codebuild` = true  |               | Github name that store source code of website/application format "{username}/{reponame}"                 |
| github_branch         | string       | true if `is_include_codebuild` = true  |               | Github branch to be deployed                                                                             |
## Output Variables

* **s3_bucket**: The name of S3 Bucket created
* **cloudfront_domain_name**: The default Cloudfront DNS name

## Sample Usage

### Without custom domain

```
module "website" {
    source    = "git@github.com:aashari/terraform-aws-static-website.git?ref=v1.1.0"
    name      = "andi.xyz"
}
```

### With custom domain

```
module "website" {
    source        = "git@github.com:aashari/terraform-aws-static-website.git?ref=v1.1.0"
    name          = "andi.xyz"
    domain_names  = ["andi.fyi", "www.andi.fyi"]

    domain_vendor = "cloudflare"
    
    cloudflare_api_key = "abcdefghijklmnopqrstuvwxyz123456"
    cloudflare_zone_id = "abcdefghijklmnopqrstuvwxyz123456"
}
```

### With AWS CodeBuild enabled

```
module "website" {
    source  = "git@github.com:aashari/terraform-aws-static-website.git?ref=v1.1.0"
    name    = "andi.xyz"
    
    is_include_codebuild = true
    github_token         = "abcdefghijklmnopqrstuvwxyz"
    github_name          = "aashari/aashari-web"
    github_branch        = "master"
}
```

### Codebuild buildspec.yaml
```
version: 0.2
phases:
  build:
    commands:
      - echo "${aws s3 sync ./build S3://$BUCKET_NAME}"
  post_build:
    commands:
      - echo "${aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID}"

```

## Contribute

Feel free to contribute, don't forget to raise an issue first then create a PR with referenced to that issue, thanks!
