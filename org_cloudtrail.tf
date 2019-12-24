
provider "aws" {
  region = "${var.region}"

  assume_role {
    role_arn = "${local.assume_role_master_payer_arn}"
  }

  alias = "master_payer"
}

data "aws_iam_role" "org_access_role" {
  name = "${var.tlz_org_account_access_role}"
  provider   = "aws.master_payer"
}

data "aws_iam_policy" "cloudtrail_full_access" {
  arn = "arn:aws:iam::aws:policy/AWSCloudTrailFullAccess"
  provider   = "aws.master_payer"
}

resource "aws_iam_role_policy_attachment" "add-cloudtrail-full-access-attach" {
  role       = "${data.aws_iam_role.org_access_role.id}"
  policy_arn = "${data.aws_iam_policy.cloudtrail_full_access.arn}"
  provider   = "aws.master_payer"
}

# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "logs:CreateLogGroup",
#                 "logs:CreateLogStream",
#                 "logs:DescribeLogStreams",
#                 "logs:PutLogEvents"
#             ],
#             "Resource": [
#                 "arn:aws:logs:REGION:ACCOUNT:log-group:/aws/Cloudtrail/*",
#                 "arn:aws:logs:us-east-2:111111111111:log-group:CloudTrail/DefaultLogGroupTest:log-stream:111111111111_CloudTrail_us-east-2*",             
#                 "arn:aws:logs:us-east-2:111111111111:log-group:CloudTrail/DefaultLogGroupTest:log-stream:o-exampleorgid_*"
#             ]
#         }
#     ]    
# }
data "aws_iam_policy_document" "orgtrail-cw-loggroup" {
  statement {
    effect    = "Allow"
    resources = [
      "${aws_cloudwatch_log_group.org-cloudtrail.arn}"
    ]

    actions = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
      ]
  }
  provider = "aws.master_payer"
}

# CW LogGroup role policy
resource "aws_iam_policy" "orgtrail-cw-loggroup" {
  name        = "tlz_orgtrail_cw_loggroup"
  description = "Allow PutLogEvents"
  policy      = "${data.aws_iam_policy_document.orgtrail-cw-loggroup.json}"
  provider = "aws.master_payer"
}

data "aws_iam_policy_document" "orgtrail-cw-loggroup-trust" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
  provider = "aws.master_payer"
}

resource "aws_iam_role" "orgtrail-cw-loggroup" {
  name        = "tlz_orgtrail_cw_loggroup"
  description        = "This role allows the cloudtrail to write to cloudwatch loggroups"
  assume_role_policy = "${data.aws_iam_policy_document.orgtrail-cw-loggroup-trust.json}"
  provider = "aws.master_payer"
}

resource "aws_iam_role_policy_attachment" "orgtrail-cw-loggroup-attach" {
  role       = "${aws_iam_role.orgtrail-cw-loggroup.id}"
  policy_arn = "${aws_iam_policy.orgtrail-cw-loggroup.arn}"
  provider   = "aws.master_payer"
}

resource "aws_cloudwatch_log_group" "org-cloudtrail" {
  name     = "tlz_org_cloudtrail/DefaultLogGroup"
  provider = "aws.master_payer"
}

resource "aws_cloudtrail" "org-cloudtrail" {
  name           = "tlz-org-cloudtrail"
  s3_bucket_name = "${var.cloudtrail_log_bucket_name}-${data.aws_caller_identity.current.account_id}"
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.org-cloudtrail.arn}"
  cloud_watch_logs_role_arn = "${aws_iam_role.orgtrail-cw-loggroup.arn}"
  #s3_key_prefix                 = "res"
  is_multi_region_trail         = true
  is_organization_trail         = true
  include_global_service_events = true
  provider                      = "aws.master_payer"
  depends_on = ["aws_iam_role_policy_attachment.add-cloudtrail-full-access-attach"]
}
