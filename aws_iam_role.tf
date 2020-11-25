resource "aws_iam_role" "subscription_filter" {
  name               = "${var.prefix}${var.name}-subscription-filter"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_subscription_filter.json

  tags = merge(
    var.tags,
    {
      "Name" = "${var.prefix}${var.name}-subscription-filter"
    },
  )
}

data "aws_iam_policy_document" "assume_role_policy_subscription_filter" {
  statement {
    effect = "Allow"

    principals {
      identifiers = [
        "logs.${var.aws_region}.amazonaws.com",
      ]

      type = "Service"
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "subscription_filter_firehose" {
  role       = aws_iam_role.subscription_filter.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFirehoseFullAccess"
}

resource "aws_iam_role" "kinesis_firehose" {
  name               = "${var.prefix}${var.name}-kinesis-firehose"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_kinesis_firehose.json

  tags = merge(
    var.tags,
    {
      "Name" = "${var.prefix}${var.name}-kinesis-firehose"
    },
  )
}

data "aws_iam_policy_document" "assume_role_policy_kinesis_firehose" {
  statement {
    effect = "Allow"

    principals {
      identifiers = [
        "firehose.amazonaws.com",
      ]

      type = "Service"
    }

    actions = [
      "sts:AssumeRole",
    ]

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"

      values = [
        data.aws_caller_identity.current.account_id
      ]
    }
  }
}

resource "aws_iam_role_policy" "kinesis_firehose" {
  name   = "KinesisFirehose"
  role   = aws_iam_role.kinesis_firehose.id
  policy = data.aws_iam_policy_document.kinesis_firehose.json
}

data "aws_iam_policy_document" "kinesis_firehose" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:AbortBucketMultipartUploads",
      "s3:PutObject",
    ]

    resources = [
      data.aws_s3_bucket.subscription_filter.arn,
      "${data.aws_s3_bucket.subscription_filter.arn}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration",
    ]

    resources = [
      aws_lambda_function.subscription_filter_processor.arn,
      "${aws_lambda_function.subscription_filter_processor.arn}:*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt",
    ]

    resources = [
      "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.current.account_id}:key/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"
    ]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"

      values = [
        "s3.ap-northeast-1.amazonaws.com"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:s3:arn"

      values = [
        "arn:aws:s3:::%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%/*"
      ]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
    ]

    resources = [
      "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.current.account_id}:key/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"
    ]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"

      values = [
        "kinesis.ap-northeast-1.amazonaws.com"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:kinesis:arn"

      values = [
        "arn:aws:kinesis:${var.aws_region}:${data.aws_caller_identity.current.account_id}:stream/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"
      ]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
    ]

    resources = [
      aws_cloudwatch_log_group.subscription_filter_firehose.arn,
      "${aws_cloudwatch_log_group.subscription_filter_firehose.arn}:*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
      "kinesis:ListShards",
    ]

    resources = [
      "arn:aws:kinesis:${var.aws_region}:${data.aws_caller_identity.current.account_id}:stream/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"
    ]
  }
}

resource "aws_iam_role" "subscription_filter_processor" {
  name               = "${var.prefix}${var.name}-subscription-filter-processor"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_lambda.json

  tags = merge(
    var.tags,
    {
      "Name" = "${var.prefix}${var.name}-subscription-filter-processor"
    },
  )
}

data "aws_iam_policy_document" "assume_role_policy_lambda" {
  statement {
    effect = "Allow"

    principals {
      identifiers = [
        "lambda.amazonaws.com",
      ]

      type = "Service"
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "subscription_filter_processor_lambda" {
  role       = aws_iam_role.subscription_filter_processor.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "subscription_filter_processor" {
  name   = "KinesisFirehose"
  role   = aws_iam_role.subscription_filter_processor.id
  policy = data.aws_iam_policy_document.subscription_filter_processor.json
}

data "aws_iam_policy_document" "subscription_filter_processor" {
  statement {
    effect = "Allow"

    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
    ]

    resources = [
      "arn:aws:firehose:${var.aws_region}:${data.aws_caller_identity.current.account_id}:deliverystream/${var.prefix}${var.name}-*"
    ]
  }
}
