resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket_name
  bucket_prefix = var.bucket_prefix

  tags = merge(var.bucket_tags, { "name" : var.bucket_name })
}
