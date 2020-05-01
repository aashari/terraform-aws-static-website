resource "aws_acm_certificate" "assets" {

  provider = aws.us-east-1
  count    = length(var.domain_names) == 0 ? 0 : 1

  domain_name               = var.domain_names[0]
  subject_alternative_names = length(var.domain_names) == 2 ? [var.domain_names[1]] : []
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = var.resource_tags

}
