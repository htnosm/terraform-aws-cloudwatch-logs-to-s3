output "this_subscription_filter_iam_role_arn" {
  description = "The ARN of the Subscription Filter."
  value       = aws_iam_role.subscription_filter.arn
}

output "this_kinesis_firehose_iam_role_arn" {
  description = "The ARN of the Kinesis Firehose."
  value       = aws_iam_role.kinesis_firehose.arn
}

output "this_kinesis_firehose_delivery_streams" {
  description = "The name of the Kinesis Firehose Delivery Stream."
  value       = sort(values(aws_kinesis_firehose_delivery_stream.subscription_filter_firehose)[*].name)
}

output "this_subscription_filters" {
  description = "The name and destination of the Subscription Filter."
  value       = zipmap(values(aws_cloudwatch_log_subscription_filter.subscription_filter)[*].log_group_name, values(aws_cloudwatch_log_subscription_filter.subscription_filter)[*].destination_arn)
}

output "this_processor_function_arn" {
  description = "The ARN of the Subscription Processor."
  value       = aws_lambda_function.subscription_filter_processor.arn
}
