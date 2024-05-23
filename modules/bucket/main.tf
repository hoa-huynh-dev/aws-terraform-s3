resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name

  tags = merge(var.bucket_tags, { "name" : var.bucket_name })
}
