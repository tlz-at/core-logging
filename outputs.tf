# IAM
output "account_id" {
  description = "Account ID"
  value       = "${var.account_id}"
}

# S3 Buckets
output "s3_cloudtrail_logs_bucket_name" {
  description = "S3 Bucket for CloudTrail logs"
  value       = "${aws_s3_bucket.s3_cloudtrail_logs.id}"
}

output "s3_cloudtrail_logs_bucket_arn" {
  description = "S3 Bucket ARN for CloudTrail logs"
  value       = "${aws_s3_bucket.s3_cloudtrail_logs.arn}"
}

output "s3_config_logs_bucket_name" {
  description = "S3 Bucket for AWS Config logs"
  value       = "${aws_s3_bucket.s3_config_logs.id}"
}

output "s3_config_logs_bucket_arn" {
  description = "S3 Bucket ARN for AWS Config logs"
  value       = "${aws_s3_bucket.s3_config_logs.arn}"
}

output "s3_guardduty_logs_bucket_name" {
  description = "S3 Bucket for GuardDuty logs"
  value       = "${aws_s3_bucket.s3_guardduty_logs.id}"
}

output "s3_guardduty_logs_bucket_arn" {
  description = "S3 Bucket ARN for GuardDuty logs"
  value       = "${aws_s3_bucket.s3_guardduty_logs.arn}"
}

output "s3_alb_access_logs_primary_bucket_name" {
  description = "S3 Bucket for primary alb_access_logs"
  value       = "${aws_s3_bucket.s3_alb_access_logs_primary.id}"
}

output "s3_alb_access_logs_primary_bucket_arn" {
  description = "S3 Bucket ARN for primary alb_access_logs"
  value       = "${aws_s3_bucket.s3_alb_access_logs_primary.arn}"
}

output "s3_alb_access_logs_secondary_bucket_name" {
  description = "S3 Bucket for secondary alb_access_logs"
  value       = "${aws_s3_bucket.s3_alb_access_logs_secondary.id}"
}

output "s3_alb_access_logs_secondary_bucket_arn" {
  description = "S3 Bucket ARN for secondary alb_access_logs"
  value       = "${aws_s3_bucket.s3_alb_access_logs_secondary.arn}"
}

# S3 Outputs
output "s3_vpc_flowlogs_bucket_name" {
  description = "S3 Bucket for VPC FlowLogs"
  value       = "${aws_s3_bucket.s3_vpc_flowlogs.id}"
}

output "s3_vpc_flowlogs_bucket_arn" {
  description = "S3 Bucket ARN for VPC FlowLogs"
  value       = "${aws_s3_bucket.s3_vpc_flowlogs.arn}"
}

# Kinesis Outputs
output "firehose_vpc_flowlogs_arn" {
  description = "Kinesis Firehose ARN for VPC FlowLogs"
  value       = "${aws_kinesis_firehose_delivery_stream.firehose_vpc_flowlogs.arn}"
}

output "vpc_flowlogs_primary_destination_arn" {
  description = "CloudWatch Destination ARN for VPC FlowLogs in primary"
  value       = "${aws_cloudwatch_log_destination.vpc_flowlogs_primary_destination.arn}"
}

output "vpc_flowlogs_secondary_destination_arn" {
  description = "CloudWatch Destination ARN for VPC FlowLogs in secondary"
  value       = "${aws_cloudwatch_log_destination.vpc_flowlogs_secondary_destination.arn}"
}

output "guardduty_firehose_role_arn" {
  description = "Role arn for guardduty firehose role in core-security account"
  value       = "${aws_iam_role.firehose_guardduty_role.arn}"
}
output "guardduty_firehose_role_name" {
  description = "Role name for guardduty firehose role in core-security account"
  value       = "${aws_iam_role.firehose_guardduty_role.name}"
}
