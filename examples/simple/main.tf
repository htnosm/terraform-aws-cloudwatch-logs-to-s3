module "subscription_filter" {
  source = "../../"

  prefix             = "simple-"
  aws_region         = "ap-northeast-1"
  aws_s3_bucket_name = "cloudwatch-logs.123456789012.ap-northeast-1"
  tags = {
    Environment = "dev"
  }

  subscription_filters = {
    "aws-lambda-myfunction" = {
      log_group_name            = "/aws/lambda/myfunction"
      filter_pattern            = ""
      buffer_interval           = 300
      buffer_size               = 5
      processor_buffer_interval = 60
      processor_buffer_size     = 3
    }
  }
  src_dir = "../../src"
}

output "subscription_filter_iam_role_arn" {
  value = module.subscription_filter.this_subscription_filter_iam_role_arn
}

output "kinesis_firehose_iam_role_arn" {
  value = module.subscription_filter.this_kinesis_firehose_iam_role_arn
}

output "kinesis_firehose_delivery_streams" {
  value = module.subscription_filter.this_kinesis_firehose_delivery_streams
}

output "subscription_filters" {
  value = module.subscription_filter.this_subscription_filters
}
