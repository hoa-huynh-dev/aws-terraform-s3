locals {
  bucket_name = "${var.bucket_prefix}-${var.bucket_name}"
}

resource "aws_s3_bucket" "bucket" {
  bucket = local.bucket_name

  tags = merge(var.bucket_tags, { "name" : var.bucket_name })
}
