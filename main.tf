/**
 * # terraform-aws-cloudwatch-logs-to-s3
 *
 * A Terraform template that transfers CloudWatch Logs to S3.
 * Output to S3 in Hive format for Athena.
 *
 * * Set the Subscription Filter for the existing LogGroup.
 * * Use Kinesis Firehose to output to an existing S3 bucket in GZIP format.
 *
 * ## Overview
 *
 * ![overview](images/terraform-aws-cloudwatch-logs-to-s3.png)
 */

terraform {
  required_version = "~> 0.13"
}

provider "aws" {
  version = "~> 3.12"
  region  = var.aws_region
}

provider "archive" {
  version = "~> 2.0.0"
}

data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "subscription_filter" {
  bucket = var.aws_s3_bucket_name
}

resource "aws_kinesis_firehose_delivery_stream" "subscription_filter_firehose" {
  for_each = var.subscription_filters

  name        = "${var.prefix}${var.name}-${each.key}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = aws_iam_role.kinesis_firehose.arn
    bucket_arn          = data.aws_s3_bucket.subscription_filter.arn
    buffer_interval     = each.value.buffer_interval
    buffer_size         = each.value.buffer_size
    compression_format  = "GZIP"
    prefix              = "${replace(each.value.log_group_name, "/^//", "")}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
    error_output_prefix = "ErrorOutput/${replace(each.value.log_group_name, "/^//", "")}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/!{firehose:error-output-type}/"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.subscription_filter_firehose.name
      log_stream_name = "${var.prefix}${var.name}-${each.key}"
    }

    processing_configuration {
      enabled = true

      processors {
        type = "Lambda"
        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.subscription_filter_processor.arn}:${aws_lambda_alias.subscription_filter_processor.function_version}"
        }


        /*
        Parameters with default values are not stored with terraform state so appear as changes.
        Ref: [Add NOTE about default processing\_configuration parameters by elrob · Pull Request \#14943 · hashicorp/terraform\-provider\-aws](https://github.com/hashicorp/terraform-provider-aws/pull/14943)
        */
        dynamic "parameters" {
          for_each = each.value.processor_buffer_interval == 60 ? [] : list(each.value.processor_buffer_interval)
          content {
            parameter_name  = "BufferIntervalInSeconds"
            parameter_value = parameters.value
          }
        }

        dynamic "parameters" {
          for_each = each.value.processor_buffer_size == 3 ? [] : list(each.value.processor_buffer_size)
          content {
            parameter_name  = "BufferSizeInMBs"
            parameter_value = parameters.value
          }
        }
      }
    }

    s3_backup_mode = "Enabled"
    s3_backup_configuration {
      bucket_arn         = data.aws_s3_bucket.subscription_filter.arn
      buffer_interval    = each.value.buffer_interval
      buffer_size        = each.value.buffer_size
      compression_format = "GZIP"
      prefix             = "source_records/"
      role_arn           = aws_iam_role.kinesis_firehose.arn

      cloudwatch_logging_options {
        enabled = false
      }
    }
  }

  server_side_encryption {
    enabled  = false
    key_type = "AWS_OWNED_CMK"
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.prefix}${var.name}-${each.key}"
    },
  )
}

resource "aws_cloudwatch_log_group" "subscription_filter_firehose" {
  name              = "/aws/kinesisfirehose/${var.prefix}${var.name}"
  retention_in_days = var.subscription_filter_firehose_log_group_retention_in_days
}

resource "aws_cloudwatch_log_subscription_filter" "subscription_filter" {
  for_each = var.subscription_filters

  name            = "Destination"
  role_arn        = aws_iam_role.subscription_filter.arn
  log_group_name  = each.value.log_group_name
  filter_pattern  = each.value.filter_pattern
  destination_arn = aws_kinesis_firehose_delivery_stream.subscription_filter_firehose[each.key].arn
  distribution    = "ByLogStream"
}
