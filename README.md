Core Logging Account
====================
Baselines the Core Logging account and its required resources

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| account\_id | The ID of the working account | string | - | yes |
| acl | The canned ACL to apply. | string | `private` | no |
| alb\_access\_log\_bucket\_us\_east\_1\_name | Name of the US-EAST-1 S3 bucket AWS Config logs | string | - | yes |
| alb\_access\_log\_bucket\_us\_west\_2\_name | Name of the us-east-2 S3 bucket AWS Config logs | string | - | yes |
| assign\_generated\_ipv6\_cidr\_block | Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block | string | `false` | no |
| azs\_primary | A list of availability zones in the region | list | `<list>` | no |
| azs\_secondary | A list of availability zones in the region | list | `<list>` | no |
| cidr\_primary | The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden | string | `0.0.0.0/0` | no |
| cidr\_secondary | The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden | string | `0.0.0.0/0` | no |
| cloudtrail\_log\_bucket\_name | Name of the S3 bucket for CloudTrail logs | string | - | yes |
| config\_log\_bucket\_name | Name of the S3 bucket AWS Config logs | string | - | yes |
| enable\_nat\_gateway | Should be true if you want to provision NAT Gateways for each of your private networks | string | `false` | no |
| secops\_aws\_monitoring\_role | Name of role for secops Splunk access | string | `secops_AWS_Monitoring_Role` | no |
| guardduty\_log\_bucket\_name | Name of the S3 bucket AWS Config logs | string | - | yes |
| name | Name of the account | string | - | yes |
| private\_subnets\_primary | A list of private subnets inside the VPC | list | `<list>` | no |
| private\_subnets\_secondary | A list of private subnets inside the VPC | list | `<list>` | no |
| region | AWS Region to deploy to | string | `us-east-2` | no |
| role\_name | AWS role name to assume | string | `OrganizationAccountAccessRole` | no |
| single\_nat\_gateway | Should be true if you want to provision a single shared NAT Gateway across all of your private networks | string | `false` | no |
| sse\_algorithm | The server-side encryption algorithm to use. Valid values are AES256 and aws:kms | string | `AES256` | no |
| tags | A map of tags to add to all resources | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| account\_alias | The alias name for the account |
| account\_id | Account ID |
| baseline\_version | Version of the baseline module |
| private\_subnets\_cidr\_blocks\_primary | List of private subnet CIDRs |
| private\_subnets\_cidr\_blocks\_secondary | List of private subnet CIDRs |
| private\_subnets\_primary | List of IDs of private subnets |
| private\_subnets\_secondary | List of IDs of private subnets |
| s3\_alb\_access\_logs\_us\_east\_1 | S3 Bucket for us-east-1 alb_access_logs |
| s3\_alb\_access\_logs\_us\_east\_1\_arn | S3 Bucket ARN for us-east-1 alb_access_logs |
| s3\_alb\_access\_logs\_us\_west\_2 | S3 Bucket for us-east-2 alb_access_logs |
| s3\_alb\_access\_logs\_us\_west\_2\_arn | S3 Bucket ARN for us-east-2 alb_access_logs |
| s3\_config\_logs | S3 Bucket for AWS Config logs |
| s3\_config\_logs\_arn | S3 Bucket ARN for AWS Config logs |
| s3\_guardduty\_logs | S3 Bucket for GuardDuty logs |
| s3\_guardduty\_logs\_arn | S3 Bucket ARN for GuardDuty logs |
| vpc\_cidr\_block\_primary | The CIDR block of the VPC |
| vpc\_cidr\_block\_secondary | The CIDR block of the VPC |
| vpc\_id\_primary | The ID of the VPC |
| vpc\_id\_secondary | The ID of the VPC |
