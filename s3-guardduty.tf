# GuardDuty S3 Bucket
resource "aws_s3_bucket" "s3_guardduty_logs" {
  bucket = "${var.guardduty_log_bucket_name}-${data.aws_caller_identity.current.account_id}"
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

data "aws_iam_policy_document" "guard_duty" {
  statement {
    sid    = "AllowFireHoseToWrite"
    effect = "Allow"

    resources = [
      "${aws_s3_bucket.s3_guardduty_logs.arn}/*",
      "${aws_s3_bucket.s3_guardduty_logs.arn}",
    ]

    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_role.firehose_guardduty_role.arn}"]
    }

    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
  }
}

resource "aws_s3_bucket_policy" "s3_guardduty_policy" {
  bucket = "${aws_s3_bucket.s3_guardduty_logs.id}"

  #policy = "${data.template_file.s3_guardduty_policy_tmpl.rendered}"
  policy = "${data.aws_iam_policy_document.guard_duty.json}"
}
