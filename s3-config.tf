# Config S3 Bucket
resource "aws_s3_bucket" "s3_config_logs" {
  bucket = "${var.config_log_bucket_name}-${data.aws_caller_identity.current.account_id}"
  acl    = "${var.acl}"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "${var.sse_algorithm}"
      }
    }
  }

  versioning {
    enabled = true
  }
}

data "aws_iam_policy_document" "config_logs" {
  statement {
    sid    = "AWSConfigBucketPermissionsCheck"
    effect = "Allow"

    resources = [
      "${aws_s3_bucket.s3_config_logs.arn}",
    ]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = ["s3:GetBucketAcl"]
  }

  statement {
    sid    = "AWSConfigBucketDelivery"
    effect = "Allow"

    resources = [
      "${aws_s3_bucket.s3_config_logs.arn}/AWSLogs/*/*",
    ]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_config_logs" {
  bucket = "${aws_s3_bucket.s3_config_logs.id}"
  policy = "${data.aws_iam_policy_document.config_logs.json}"
}
