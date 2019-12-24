# ALB Access Logs S3 Buckets
resource "aws_iam_role" "alb_access_log_replication" {
  name               = "tlz_alb_access_log_replication_${data.aws_caller_identity.current.account_id}"
  description        = "S3 Bucket Policies defined within the core logging account which ingests the ALB Logs"
  assume_role_policy = "${data.aws_iam_policy_document.alb_access_log_replication_assume_policy.json}"
}

data "aws_iam_policy_document" "alb_access_log_replication_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

data "template_file" "alb_access_log_replication_policy" {
  template = "${file("${path.module}/templates/alb_access_log_bucket_replication_policy.json.tpl")}"

  vars = {
    destination_bucket_arn = "${aws_s3_bucket.s3_alb_access_logs_primary.arn}"
    secondary_bucket_arn   = "${aws_s3_bucket.s3_alb_access_logs_secondary.arn}"
  }
}

resource "aws_iam_policy" "alb_access_log_replication" {
  name   = "tlz_alb_access_log_replication"
  policy = "${data.template_file.alb_access_log_replication_policy.rendered}"
}

resource "aws_iam_policy_attachment" "alb_access_log_replication" {
  name       = "alb-access-log-replication"
  roles      = ["${aws_iam_role.alb_access_log_replication.name}"]
  policy_arn = "${aws_iam_policy.alb_access_log_replication.arn}"
}

resource "aws_s3_bucket" "s3_alb_access_logs_primary" {
  bucket = "${var.alb_access_log_bucket_primary_name}-${data.aws_caller_identity.current.account_id}"
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

resource "aws_s3_bucket" "s3_alb_access_logs_secondary" {
  provider = "aws.secondary"
  region   = "${var.region_secondary}"
  bucket   = "${var.alb_access_log_bucket_secondary_name}-${data.aws_caller_identity.current.account_id}"
  acl      = "${var.acl}"

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

  replication_configuration {
    role = "${aws_iam_role.alb_access_log_replication.arn}"

    rules {
      status = "Enabled"

      destination {
        bucket        = "${aws_s3_bucket.s3_alb_access_logs_primary.arn}"
        storage_class = "STANDARD"
      }
    }
  }
}
