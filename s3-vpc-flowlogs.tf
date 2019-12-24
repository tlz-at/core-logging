# VPC FlowLogs S3 Bucket

resource "aws_s3_bucket" "s3_vpc_flowlogs" {
  bucket = "${var.vpc_flowlogs_bucket_name}-${data.aws_caller_identity.current.account_id}"
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
