resource "aws_s3_bucket" "packages" {
  bucket = var.bucket_name
  tags = merge(var.aws_tags, {
    gl_resource_name = var.bucket_name
    gl_resource_type = "storage-bucket"
  })
}

resource "aws_s3_bucket_versioning" "packages" {
  bucket = aws_s3_bucket.packages.id

  versioning_configuration {
    status = var.bucket_replication.name != "" || var.bucket_versioning_enabled ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "packages" {
  bucket = aws_s3_bucket.packages.id

  rule {
    id = "clean versions after 30 days"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    status = "Enabled"
  }

  rule {
    id = "intelligent-access"

    transition {
      days          = 14
      storage_class = "INTELLIGENT_TIERING"
    }

    status = "Enabled"
  }
}

###########################
#
# Optional S3 replication configuration

resource "aws_s3_bucket" "replication" {
  count = var.bucket_replication.name != "" ? 1 : 0

  bucket = var.bucket_replication.name
  tags = merge(var.aws_tags, {
    gl_resource_name = var.bucket_replication.name
    gl_resource_type = "storage-bucket"
  })
  provider = aws.replication
}

data "aws_iam_policy_document" "assume_role" {
  count = var.bucket_replication.name != "" ? 1 : 0

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
  count = var.bucket_replication.name != "" ? 1 : 0

  name               = "packages-s3-replication"
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
}

data "aws_iam_policy_document" "replication" {
  count = var.bucket_replication.name != "" ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [aws_s3_bucket.packages.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = ["${aws_s3_bucket.packages.arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${aws_s3_bucket.replication[0].arn}/*"]
  }
}

resource "aws_iam_policy" "replication" {
  count = var.bucket_replication.name != "" ? 1 : 0

  name   = "packages-replication"
  policy = data.aws_iam_policy_document.replication[0].json
}

resource "aws_iam_role_policy_attachment" "replication" {
  count = var.bucket_replication.name != "" ? 1 : 0

  role       = aws_iam_role.replication[0].name
  policy_arn = aws_iam_policy.replication[0].arn
}

resource "aws_s3_bucket_versioning" "replication" {
  count = var.bucket_replication.name != "" ? 1 : 0

  provider = aws.replication

  bucket = aws_s3_bucket.replication[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  count = var.bucket_replication.name != "" ? 1 : 0

  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.packages]

  role   = aws_iam_role.replication[0].arn
  bucket = aws_s3_bucket.packages.id

  rule {
    id = "replicate all objects"

    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.replication[0].arn
      storage_class = var.bucket_replication.storage_class
    }
  }
}
