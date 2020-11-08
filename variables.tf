variable aws_region {
  description = "AWS Region"
  type        = string
}

variable aws_s3_bucket_name {
  description = "Destination S3 bucket"
  type        = string
}

variable tags {
  description = "(Optional) A mapping of tags to assign to resources."
  type        = map(string)

  default = {}
}

variable prefix {
  description = "(Optional) Specified prefix assign to resources."
  type        = string
  default     = ""
}

variable name {
  description = "name assign to resources."
  type        = string
  default     = "cwl2s3"
}

variable subscription_filters {
  description = <<EOT
CloudWatch Logs Subscription Filters.

The Key is the name of the delivery stream, and the "{prefix}{name}-" is added.
For example, if you specify "myloggroup" as Key, the delivery stream name will be "{prefix}{name}-myloggroup".
EOT

  type = map(object({
    log_group_name  = string
    filter_pattern  = string
    buffer_interval = number
    buffer_size     = number
  }))
}

variable subscription_filter_firehose_log_group_retention_in_days {
  description = "(Optional) Kinesis Firehose error logging retention in days."
  type        = number
  default     = 60
}

variable subscription_filter_processor_timeout {
  description = "(Optional) Lambda Function timeout seconds."
  type        = number
  default     = 60
}

variable subscription_filter_processor_memory_size {
  description = "(Optional) Lambda Function memory size(MB)."
  type        = number
  default     = 128
}

variable subscription_filter_processor_log_group_retention_in_days {
  description = "(Optional) Lambda Function logging retention in days."
  type        = number
  default     = 60
}

variable src_dir {
  description = "Lambda Function source directory for transform source records. (specify a relative path to ./src)"
  type        = string
}
