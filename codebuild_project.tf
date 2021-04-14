resource "random_id" "aws_iam_role_assets" {
  byte_length = 4
}

resource "random_id" "aws_codebuild_project_assets" {
  byte_length = 4
}

locals {
  codebuild_name = "${replace(var.name, ".", "-")}-builder-${random_id.aws_iam_role_assets.hex}"
}

resource "aws_iam_role" "assets" {
  name = "codebuild-${local.codebuild_name}"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          Effect : "Allow",
          Principal : {
            "Service" : "codebuild.amazonaws.com"
          },
          Action : "sts:AssumeRole"
        }
      ]
    }
  )
  tags = var.resource_tags
}

resource "aws_iam_role_policy" "aws_iam_role_assets_default_policy" {
  name = "default"
  role = aws_iam_role.assets.name
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          Effect : "Allow",
          Resource : [
            "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${local.codebuild_name}",
            "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${local.codebuild_name}:*"
          ],
          Action : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
        },
        {
          Effect : "Allow",
          Action : [
            "codebuild:CreateReportGroup",
            "codebuild:CreateReport",
            "codebuild:UpdateReport",
            "codebuild:BatchPutTestCases"
          ],
          Resource : [
            "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:report-group/${local.codebuild_name}-*"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "aws_iam_role_assets_cloudfront_policy" {
  name = "cloudfront"
  role = aws_iam_role.assets.name
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          Effect : "Allow",
          Action : "cloudfront:CreateInvalidation",
          Resource : aws_cloudfront_distribution.server.arn
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "aws_iam_role_assets_s3_policy" {
  name = "s3"
  role = aws_iam_role.assets.name
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          Effect : "Allow",
          Action : [
            "s3:PutObject",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:ListObjectsV2"
          ],
          Resource : [
            aws_s3_bucket.assets.arn,
            "${aws_s3_bucket.assets.arn}/*",
          ]
        }
      ]
    }
  )
}

resource "aws_codebuild_project" "assets" {

  count = var.is_include_codebuild ? 1 : 0

  name          = local.codebuild_name
  description   = local.codebuild_name
  build_timeout = "5"
  service_role  = aws_iam_role.assets.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "BUCKET_NAME"
      value = aws_s3_bucket.assets.bucket
    }

    environment_variable {
      name  = "DISTRIBUTION_ID"
      value = aws_cloudfront_distribution.server.id
    }

    dynamic "environment_variable" {
      for_each = var.codebuild_environment_variables
      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
      }
    }

  }

  logs_config {
    cloudwatch_logs {
    }
  }

  source {
    type            = "GITHUB"
    git_clone_depth = 1
    location        = "https://github.com/${var.github_name}"
    auth {
      type     = "OAUTH"
      resource = aws_codebuild_source_credential.github[0].arn
    }
  }

  source_version = var.github_branch
  tags           = var.resource_tags

}

resource "aws_codebuild_source_credential" "github" {
  count       = var.is_include_codebuild ? 1 : 0
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.github_token
}

resource "aws_codebuild_webhook" "example" {
  count        = var.is_include_codebuild ? 1 : 0
  project_name = aws_codebuild_project.assets[0].name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "HEAD_REF"
      pattern = var.github_branch
    }
  }
}
