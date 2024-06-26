locals {
  bucket_name                   = "${var.bucket_prefix}-${var.bucket_name}"
  bucket_notification_sqs_count = var.bucket_notification_sqs != null ? (var.bucket_notification_sqs.queue_name != null ? 1 : 0) : 0
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
      id     = "${var.bucket_prefix}-${var.bucket_name}-lifecycle-rule-${rule.key}"
      status = "Enabled"

      filter {
        prefix = rule.value.prefix
      }

      dynamic "transition" {
        for_each = rule.value.current_version_transitions
        content {
          storage_class = transition.key
          days          = transition.value
        }
      }

      dynamic "expiration" {
        for_each = rule.value.current_version_expiration > 0 ? [1] : []
        content {
          days = rule.value.current_version_expiration
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transitions
        content {
          storage_class   = noncurrent_version_transition.key
          noncurrent_days = noncurrent_version_transition.value
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration > 0 ? [1] : []
        content {
          noncurrent_days = rule.value.noncurrent_version_expiration
        }
      }
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_server_side_encryption_configuration" {
  bucket = aws_s3_bucket.bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.sse_algorithm
    }
  }
}

data "aws_iam_policy_document" "sqs_iam_policy" {
  count = local.bucket_notification_sqs_count
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [data.aws_sqs_queue.queue[0].arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.bucket.arn]
    }
  }
}

data "aws_sqs_queue" "queue" {
  count = local.bucket_notification_sqs_count
  name  = var.bucket_notification_sqs.queue_name
}

resource "aws_sqs_queue_policy" "queue_policy" {
  count     = local.bucket_notification_sqs_count
  queue_url = data.aws_sqs_queue.queue[0].url
  policy    = data.aws_iam_policy_document.sqs_iam_policy[0].json
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = local.bucket_notification_sqs_count
  bucket = aws_s3_bucket.bucket.bucket

  queue {
    queue_arn     = data.aws_sqs_queue.queue[0].arn
    events        = var.bucket_notification_sqs.events
    filter_prefix = var.bucket_notification_sqs.filter_prefix
    filter_suffix = var.bucket_notification_sqs.filter_suffix
  }
}
