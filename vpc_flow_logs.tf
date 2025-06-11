resource "aws_flow_log" "vpc" {
  count                = var.enable_vpc_flow_logs ? 1 : 0
  log_destination      = aws_s3_bucket.vpc_flow_logs[count.index].arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.vpc.id
  tags                 = local.default_module_tags
}

resource "aws_s3_bucket" "vpc_flow_logs" {
  count         = var.enable_vpc_flow_logs ? 1 : 0
  bucket_prefix = "vpc-flow-logs-${replace(var.service_name, " ", "-")}-"
  force_destroy = true
  tags          = local.default_module_tags
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  count                   = var.enable_vpc_flow_logs ? 1 : 0
  bucket                  = aws_s3_bucket.vpc_flow_logs[count.index].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "enabled" {
  count  = var.enable_vpc_flow_logs ? 1 : 0
  bucket = aws_s3_bucket.vpc_flow_logs[count.index].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  count  = var.enable_vpc_flow_logs ? 1 : 0
  bucket = aws_s3_bucket.vpc_flow_logs[count.index].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "vpc_flow_logs" {
  count  = var.enable_vpc_flow_logs ? 1 : 0
  bucket = aws_s3_bucket_versioning.enabled[count.index].bucket
  rule {
    id     = "delete-old"
    status = "Enabled"
    filter {
      object_size_greater_than = 0
    }
    expiration {
      days = var.vpc_flow_retention_days
    }
    noncurrent_version_expiration {
      noncurrent_days = var.vpc_flow_retention_days
    }
  }
}

resource "aws_s3_bucket_policy" "vpc_flow_logs" {
  count  = var.enable_vpc_flow_logs ? 1 : 0
  bucket = aws_s3_bucket.vpc_flow_logs[count.index].id
  policy = data.aws_iam_policy_document.vpc_flow_logs[count.index].json
}

data "aws_iam_policy_document" "vpc_flow_logs" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.vpc_flow_logs[count.index].arn,
      "${aws_s3_bucket.vpc_flow_logs[count.index].arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
  }
  statement {
    sid = "AWSLogDeliveryWrite1"
    actions = [
      "s3:PutObject"
    ]
    condition {
      test = "ArnLike"
      values = [
        "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      ]
      variable = "aws:SourceArn"
    }
    condition {
      test = "StringEquals"
      values = [
        data.aws_caller_identity.current.account_id
      ]
      variable = "aws:SourceAccount"
    }
    condition {
      test = "StringEquals"
      values = [
        "bucket-owner-full-control"
      ]
      variable = "s3:x-amz-acl"
    }
    principals {
      identifiers = [
        "delivery.logs.amazonaws.com"
      ]
      type = "Service"
    }
    resources = [
      "${aws_s3_bucket.vpc_flow_logs[count.index].arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]
  }
  statement {
    sid = "AWSLogDeliveryAclCheck1"
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "s3:GetBucketAcl"
    ]
    resources = [
      aws_s3_bucket.vpc_flow_logs[count.index].arn
    ]
    condition {
      test = "ArnLike"
      values = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
      variable = "aws:SourceArn"
    }
    condition {
      test = "StringEquals"
      values = [
        data.aws_caller_identity.current.account_id
      ]
      variable = "aws:SourceAccount"
    }
  }
}
