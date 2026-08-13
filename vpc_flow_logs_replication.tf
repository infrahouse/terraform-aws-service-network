resource "aws_s3_bucket" "vpc_flow_logs_replica" {
  region = var.replication_region
  # AWS limits bucket_prefix to 37 characters
  bucket_prefix = substr("vpc-flow-logs-${replace(var.service_name, " ", "-")}-replica-", 0, 37)
  force_destroy = var.flow_logs_force_destroy
  tags = merge(
    local.default_module_tags,
    {
      "vanta-exempt:aws-s3-cross-region-replication-enabled" = join("", [
        "Replica destination bucket",
        " - CRR test applies to source not target",
      ])
    },
  )
}

resource "aws_s3_bucket_public_access_block" "vpc_flow_logs_replica" {
  region                  = var.replication_region
  bucket                  = aws_s3_bucket.vpc_flow_logs_replica.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "vpc_flow_logs_replica" {
  region = var.replication_region
  bucket = aws_s3_bucket.vpc_flow_logs_replica.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "vpc_flow_logs_replica" {
  region = var.replication_region
  bucket = aws_s3_bucket.vpc_flow_logs_replica.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "vpc_flow_logs_replica" {
  region = var.replication_region
  bucket = aws_s3_bucket.vpc_flow_logs_replica.id
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

resource "aws_s3_bucket_policy" "vpc_flow_logs_replica" {
  region = var.replication_region
  bucket = aws_s3_bucket.vpc_flow_logs_replica.id
  policy = data.aws_iam_policy_document.vpc_flow_logs_replica.json
}

data "aws_iam_policy_document" "vpc_flow_logs_replica" {
  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.vpc_flow_logs_replica.arn,
      "${aws_s3_bucket.vpc_flow_logs_replica.arn}/*",
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

data "aws_iam_policy_document" "replication_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "replication" {
  name_prefix        = "vpc-flow-logs-crr-"
  assume_role_policy = data.aws_iam_policy_document.replication_assume_role.json
  tags               = local.default_module_tags
}

data "aws_iam_policy_document" "replication" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.vpc_flow_logs[0].arn,
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]
    resources = [
      "${aws_s3_bucket.vpc_flow_logs[0].arn}/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]
    resources = [
      "${aws_s3_bucket.vpc_flow_logs_replica.arn}/*",
    ]
  }
}

resource "aws_iam_role_policy" "replication" {
  name   = "replication"
  role   = aws_iam_role.replication.id
  policy = data.aws_iam_policy_document.replication.json
}

resource "aws_s3_bucket_replication_configuration" "vpc_flow_logs" {
  bucket = aws_s3_bucket.vpc_flow_logs[0].id
  role   = aws_iam_role.replication.arn

  rule {
    id     = "replicate-all"
    status = "Enabled"

    filter {}

    delete_marker_replication {
      status = "Enabled"
    }

    destination {
      bucket        = aws_s3_bucket.vpc_flow_logs_replica.arn
      storage_class = "STANDARD_IA"
    }
  }

  lifecycle {
    precondition {
      condition     = var.replication_region != data.aws_region.current.region
      error_message = <<-EOT
        replication_region must be different from the current region
        (${data.aws_region.current.region}). Got: ${var.replication_region}
      EOT
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.enabled,
    aws_s3_bucket_versioning.vpc_flow_logs_replica,
  ]
}
