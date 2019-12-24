# Create a Kinesis Firehose delivery stream for VPC FlowLogs
resource "aws_kinesis_firehose_delivery_stream" "firehose_vpc_flowlogs" {
  name        = "tlz_vpc_flowlogs_firehose_stream"
  destination = "s3"

  s3_configuration {
    role_arn           = "${aws_iam_role.firehose_vpc_flowlogs_role.arn}"
    bucket_arn         = "${aws_s3_bucket.s3_vpc_flowlogs.arn}"
    buffer_size        = "${var.kinesis_s3_buffer_size}"
    buffer_interval    = "${var.kinesis_s3_buffer_interval}"
    compression_format = "${var.kinesis_s3_compression_format}"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "/aws/kinesisfirehose/vpc-flowlogs-firehose-stream"
      log_stream_name = "S3Delivery"
    }
  }
}

module "firehose_vpc_flowlogs_label" {
  source    = "cloudposse/label/null"
  version   = "0.10.0"
  namespace = "tlz"
  name      = "firehose_vpcflowlogs"
  #attributes = ["public"]
  delimiter = "_"
  tags      = "${map("BusinessUnit", "RES")}"
}

resource "aws_iam_role" "firehose_vpc_flowlogs_role" {
  name               = "${module.firehose_vpc_flowlogs_label.id}"
  description        = "Role for the vpcflowlogs"
  tags               = "${module.firehose_vpc_flowlogs_label.tags}"
  assume_role_policy = "${data.aws_iam_policy_document.firehose_vpc_flowlogs_assume_policy.json}"
}

data "aws_iam_policy_document" "firehose_vpc_flowlogs_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "firehose_vpc_flowlogs_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.s3_vpc_flowlogs.arn}",
      "${aws_s3_bucket.s3_vpc_flowlogs.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "firehose_vpc_flowlogs_role_policy" {
  name   = "tlz_firehose_vpc_flowlogs_role_policy"
  policy = "${data.aws_iam_policy_document.firehose_vpc_flowlogs_role_policy.json}"
}

resource "aws_iam_policy_attachment" "firehose_vpc_flowlogs_role_policy" {
  name       = "tlz_firehose_vpc_flowlogs_role_policy"
  roles      = ["${aws_iam_role.firehose_vpc_flowlogs_role.name}"]
  policy_arn = "${aws_iam_policy.firehose_vpc_flowlogs_role_policy.arn}"
}

# Create CloudWatch Log Group Desintations
resource "aws_cloudwatch_log_destination" "vpc_flowlogs_primary_destination" {
  name       = "tlz_vpc_flowlogs_primary_destination"
  role_arn   = "${aws_iam_role.vpc_flowlogs_destination_role.arn}"
  target_arn = "${aws_kinesis_firehose_delivery_stream.firehose_vpc_flowlogs.arn}"
}

resource "aws_cloudwatch_log_destination" "vpc_flowlogs_secondary_destination" {
  name       = "tlz_vpc_flowlogs_secondary_destination"
  provider   = "aws.secondary"
  role_arn   = "${aws_iam_role.vpc_flowlogs_destination_role.arn}"
  target_arn = "${aws_kinesis_firehose_delivery_stream.firehose_vpc_flowlogs.arn}"
}

resource "aws_iam_role" "vpc_flowlogs_destination_role" {
  name               = "tlz_vpc_flowlogs_destination_role"
  description        = "CloudWatch to Kinesis Firehose trust policy applied to the Kinesis Service"
  assume_role_policy = "${data.aws_iam_policy_document.vpc_flowlogs_destination_assume_policy.json}"
}

data "aws_iam_policy_document" "vpc_flowlogs_destination_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "logs.${var.region}.amazonaws.com",
        "logs.${var.region_secondary}.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "vpc_flowlogs_destination_role_policy" {
  statement {
    effect    = "Allow"
    actions   = ["firehose:*"]
    resources = ["arn:aws:firehose:${var.region}:${var.account_id}:*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::${var.account_id}:role/CloudWatchRole"]
  }
}

resource "aws_iam_policy" "vpc_flowlogs_destination_role_policy" {
  name   = "tlz_vpc_flowlogs_destination_role_policy"
  policy = "${data.aws_iam_policy_document.vpc_flowlogs_destination_role_policy.json}"
}

resource "aws_iam_policy_attachment" "vpc_flowlogs_destination_role_policy" {
  name       = "tlz_vpc_flowlogs_destination_role_policy"
  roles      = ["${aws_iam_role.vpc_flowlogs_destination_role.name}"]
  policy_arn = "${aws_iam_policy.vpc_flowlogs_destination_role_policy.arn}"
}
