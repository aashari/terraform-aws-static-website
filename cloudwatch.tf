resource "aws_cloudwatch_log_group" "aws_codebuild_project_assets" {
  for_each          = { for opt in aws_codebuild_project.assets : opt.id => opt }
  retention_in_days = var.cloudwatch_logs_retention
  name              = format("/aws/codebuild/%s", each.value.name)
}
