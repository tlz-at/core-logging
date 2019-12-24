# Cloudtrail S3 Bucket
resource "aws_s3_bucket" "s3_cloudtrail_logs" {
  bucket = "${var.cloudtrail_log_bucket_name}-${data.aws_caller_identity.current.account_id}"
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

  tags = {
    "Environment"        = "prd"
    "Managed"            = "tfe"
    "Name"               = "tlz-cloudtrail-central"
    "OrganizationalUnit" = "core"
    "Owner"              = "cloudops"
  }
}

data "aws_iam_policy_document" "cloudtrail_logs" {
  statement {
    sid    = "AWSBucketPermissionsCheck"
    effect = "Allow"

    resources = [
      "${aws_s3_bucket.s3_cloudtrail_logs.arn}",
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["s3:GetBucketAcl"]
  }

  statement {
    sid    = "AWSBucketDelivery"
    effect = "Allow"

    resources = [
      "${aws_s3_bucket.s3_cloudtrail_logs.arn}/AWSLogs/*/*",
      "${aws_s3_bucket.s3_cloudtrail_logs.arn}/AWSLogs/${var.master_payer_org_id}/*",
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid    = "DenyUnencryptedObjectUploads"
    effect = "Deny"

    resources = [
      "${aws_s3_bucket.s3_cloudtrail_logs.arn}",
      "${aws_s3_bucket.s3_cloudtrail_logs.arn}/AWSLogs/*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:PutObject"]

    condition {
      test     = "Bool"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["true"]
    }
  }

  statement {
    sid    = "DenyUnsecuredTransport"
    effect = "Deny"

    resources = [
      "${aws_s3_bucket.s3_cloudtrail_logs.arn}",
      "${aws_s3_bucket.s3_cloudtrail_logs.arn}/AWSLogs/*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_cloudtrail_logs" {
  bucket = "${aws_s3_bucket.s3_cloudtrail_logs.id}"
  policy = "${data.aws_iam_policy_document.cloudtrail_logs.json}"
}
