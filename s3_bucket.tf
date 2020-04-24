resource "random_id" "aws_s3_bucket_assets" {
  byte_length = 4
}

resource "aws_s3_bucket" "assets" {
  bucket = "${var.name}-assets-${data.aws_caller_identity.current.account_id}-${random_id.aws_s3_bucket_assets.hex}"
  acl    = "private"

  versioning {
    enabled = var.is_versioning_enabled
  }
}