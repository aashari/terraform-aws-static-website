resource "aws_cloudwatch_log_group" "aws_codebuild_project_assets" {
  retention_in_days = var.cloudwatch_logs_retention
}
