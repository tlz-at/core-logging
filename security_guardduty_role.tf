provider "aws" {
  region = "${var.region}"

  assume_role {
    role_arn = "${local.assume_role_security_arn}"
  }

  alias = "core_security"
}

# Set up the role for Firehose to write to the GuardDuty bucket
resource "aws_iam_role" "firehose_guardduty_role" {
  name               = "tlz_firehose_guardduty"
  assume_role_policy = "${data.aws_iam_policy_document.firehose_guardduty_assume_policy.json}"
  provider           = "aws.core_security"
}

data "aws_iam_policy_document" "firehose_guardduty_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "firehose_guardduty_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]

    resources = [
      "${aws_s3_bucket.s3_guardduty_logs.arn}",
      "${aws_s3_bucket.s3_guardduty_logs.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "firehose_guardduty_role_policy" {
  name     = "tlz_firehose_guardduty_role_policy"
  policy   = "${data.aws_iam_policy_document.firehose_guardduty_role_policy.json}"
  provider = "aws.core_security"
}

resource "aws_iam_policy_attachment" "firehose_guardduty_role_policy" {
  name       = "tlz_firehose_guardduty_role_policy"
  roles      = ["${aws_iam_role.firehose_guardduty_role.name}"]
  policy_arn = "${aws_iam_policy.firehose_guardduty_role_policy.arn}"
  provider   = "aws.core_security"
}
