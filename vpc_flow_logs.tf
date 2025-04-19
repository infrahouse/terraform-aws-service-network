resource "aws_flow_log" "vpc" {
  count                = var.enable_vpc_flow_logs ? 1 : 0
  log_destination      = aws_s3_bucket.vpc_flow_logs[count.index].arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.vpc.id
  tags                 = var.tags
}

resource "aws_s3_bucket" "vpc_flow_logs" {
  count         = var.enable_vpc_flow_logs ? 1 : 0
  bucket_prefix = "vpc-flow-logs-${replace(var.service_name, " ", "-")}-"
  force_destroy = true
  tags          = var.tags
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
