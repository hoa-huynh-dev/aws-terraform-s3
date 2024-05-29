locals {
  bucket_name = "${var.bucket_prefix}-${var.bucket_name}"
}

resource "aws_s3_bucket" "bucket" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy
  tags          = merge(var.bucket_tags, { "name" : local.bucket_name })
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access_block" {
  bucket                  = aws_s3_bucket.bucket.bucket
  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.bucket
  versioning_configuration {
    status = var.enable_bucket_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  count  = var.bucket_policy_document == null ? 0 : 1
  bucket = aws_s3_bucket.bucket.bucket
  policy = var.bucket_policy_document
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle_configuration" {
  count  = length(var.bucket_lifecycle_rules) == 0 ? 0 : 1
  bucket = aws_s3_bucket.bucket.bucket

  dynamic "rule" {
    for_each = var.bucket_lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status

      filter {
        prefix = rule.value.prefix == null ? "" : rule.value.prefix
      }

      dynamic "transition" {
        for_each = rule.value.transitions
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }
    }
  }
}
