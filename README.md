# terraform-aws-cloudwatch-logs-to-s3

A Terraform template that transfers CloudWatch Logs to S3.
Output to S3 in Hive format for Athena.

* Set the Subscription Filter for the existing LogGroup.
* Use Kinesis Firehose to output to an existing S3 bucket in GZIP format.

## Overview

![overview](images/terraform-aws-cloudwatch-logs-to-s3.png)

### S3 output prefix
- prefix
  - {s3\_bucket\_prefix}{CloudWatch LogGroup Name}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
- error prefix
  - {s3\_bucket\_prefix}ErrorOutput/{CloudWatch LogGroup Name}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"

## Known Issues

For buffer\_size and buffer\_interval, processor\_buffer\_size and processor\_buffer\_interval, if you want to use non-default values, you need to change both.
e.g. Specifid processor\_buffer\_size as 1 MB, set the processor\_buffer\_interval to something like 61 sec.

> \# [aws\\_kinesis\\_firehose\\_delivery\\_stream \| Resources \| hashicorp/aws \| Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream#argument-reference)
> NOTE:
> Parameters with default values, including NumberOfRetries(default: 3), RoleArn(default: firehose role ARN), BufferSizeInMBs(default: 3), and BufferIntervalInSeconds(default: 60), are not stored in terraform state. To prevent perpetual differences, it is therefore recommended to only include parameters with non-default values.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | >= 2.2 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.12 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.subscription_filter_firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.subscription_filter_processor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_stream.subscription_filter_firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_cloudwatch_log_subscription_filter.subscription_filter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |
| [aws_iam_role.kinesis_firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.subscription_filter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.subscription_filter_processor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.kinesis_firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.subscription_filter_processor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.subscription_filter_firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.subscription_filter_processor_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kinesis_firehose_delivery_stream.subscription_filter_firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lambda_alias.subscription_filter_processor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_alias) | resource |
| [aws_lambda_function.subscription_filter_processor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [archive_file.lambda_function_subscription_filter_processor](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role_policy_kinesis_firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume_role_policy_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume_role_policy_subscription_filter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kinesis_firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.subscription_filter_processor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this_kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_s3_bucket.subscription_filter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | name assign to resources. | `string` | `"cwl2s3"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | (Optional) Specified prefix assign to resources. | `string` | `""` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Destination S3 bucket | `string` | n/a | yes |
| <a name="input_s3_output_prefix"></a> [s3\_output\_prefix](#input\_s3\_output\_prefix) | (Optional) You can specify an extra prefix to be added in front of the time format prefix. Note that if the prefix ends with a slash, it appears as a folder in the S3 bucket. | `string` | `""` | no |
| <a name="input_src_dir"></a> [src\_dir](#input\_src\_dir) | Lambda Function source directory for transform source records. (specify a relative path to ./src) | `string` | n/a | yes |
| <a name="input_subscription_filter_firehose_log_group_retention_in_days"></a> [subscription\_filter\_firehose\_log\_group\_retention\_in\_days](#input\_subscription\_filter\_firehose\_log\_group\_retention\_in\_days) | (Optional) Kinesis Firehose error logging retention in days. | `number` | `60` | no |
| <a name="input_subscription_filter_processor_log_group_retention_in_days"></a> [subscription\_filter\_processor\_log\_group\_retention\_in\_days](#input\_subscription\_filter\_processor\_log\_group\_retention\_in\_days) | (Optional) Lambda Function logging retention in days. | `number` | `60` | no |
| <a name="input_subscription_filter_processor_memory_size"></a> [subscription\_filter\_processor\_memory\_size](#input\_subscription\_filter\_processor\_memory\_size) | (Optional) Lambda Function memory size(MB). | `number` | `128` | no |
| <a name="input_subscription_filter_processor_timeout"></a> [subscription\_filter\_processor\_timeout](#input\_subscription\_filter\_processor\_timeout) | (Optional) Lambda Function timeout seconds. | `number` | `60` | no |
| <a name="input_subscription_filters"></a> [subscription\_filters](#input\_subscription\_filters) | CloudWatch Logs Subscription Filters.<br><br>The Key is the name of the delivery stream, and the "{prefix}{name}-" is added.<br>For example, if you specify "myloggroup" as Key, the delivery stream name will be "{prefix}{name}-myloggroup".<br><br>[CloudWatch Log]<br>log\_group\_name = Log group name<br>filter\_pattern = Subscription filter pattern ("" matches all log events)<br><br>[Firehose]<br>buffer\_interval           = S3 buffer conditions interval(secounds). Default 300<br>buffer\_size               = S3 buffer conditions size(MiB). Default 5<br>processor\_buffer\_interval = Lambda buffer interval(secounds). Default 60<br>processor\_buffer\_size     = Lambda buffer conditions size(MiB). Default 3 | <pre>map(object({<br>    log_group_name            = string<br>    filter_pattern            = string<br>    buffer_interval           = number<br>    buffer_size               = number<br>    processor_buffer_interval = number<br>    processor_buffer_size     = number<br>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_this_kinesis_firehose_delivery_streams"></a> [this\_kinesis\_firehose\_delivery\_streams](#output\_this\_kinesis\_firehose\_delivery\_streams) | The name of the Kinesis Firehose Delivery Stream. |
| <a name="output_this_kinesis_firehose_iam_role_arn"></a> [this\_kinesis\_firehose\_iam\_role\_arn](#output\_this\_kinesis\_firehose\_iam\_role\_arn) | The ARN of the Kinesis Firehose. |
| <a name="output_this_processor_function_arn"></a> [this\_processor\_function\_arn](#output\_this\_processor\_function\_arn) | The ARN of the Subscription Processor. |
| <a name="output_this_subscription_filter_iam_role_arn"></a> [this\_subscription\_filter\_iam\_role\_arn](#output\_this\_subscription\_filter\_iam\_role\_arn) | The ARN of the Subscription Filter. |
| <a name="output_this_subscription_filters"></a> [this\_subscription\_filters](#output\_this\_subscription\_filters) | The name and destination of the Subscription Filter. |
