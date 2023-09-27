resource "aws_iam_user" "packagecloud" {
  name = "packagecloud-${var.environment}"
  tags = var.aws_tags
}

resource "aws_iam_access_key" "packagecloud" {
  user = aws_iam_user.packagecloud.name
}

data "aws_iam_policy_document" "cloudfront" {
  statement {
    actions = [
      "kms:*",
      "lambda:*",
      "cloudfront:*"
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "iam" {
  # Required for bootstrapping
  statement {
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreatePolicy",
      "iam:CreateRole",
      "iam:CreateServiceLinkedRole",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:GetServiceLinkedRoleDeletionStatus",
      "iam:ListAttachedRolePolicies",
      "iam:ListPolicies",
      "iam:ListPolicyVersions",
      "iam:ListRolePolicies",
      "iam:ListRoles",
      "iam:ListRoleTags",
      "iam:PassRole",
      "iam:PutRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateRole",
      "iam:UpdateRoleDescription"
    ]

    resources = [
      "arn:aws:iam:::role/packagecloud/enterprise/*",
      "arn:aws:iam:::role/packagecloud/enterprise",
      "arn:aws:iam::*:role/aws-service-role/*",
      "arn:aws:iam:::policy/packagecloud/enterprise/*",
      "arn:aws:iam:::policy/packagecloud/enterprise"
    ]
  }
}

data "aws_iam_policy_document" "s3" {
  statement {
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.packages.arn}/*"]
  }

  statement {
    actions   = ["s3:*"]
    resources = ["${aws_s3_bucket.packages.arn}/*"]
  }
}

resource "aws_iam_policy" "cloudfront" {
  name        = "Cloudfront"
  description = "Policy to allow the packagecloud AWS user to access/bootstrap Cloudfront"
  path        = "/"
  policy      = data.aws_iam_policy_document.cloudfront.json
  tags        = var.aws_tags
}

resource "aws_iam_policy" "iam" {
  name        = "IAM"
  description = "Policy to allow the packagecloud AWS user IAM access to bootstrap packagecloud:enterprise"
  path        = "/"
  policy      = data.aws_iam_policy_document.iam.json
  tags        = var.aws_tags
}

resource "aws_iam_policy" "s3" {
  name        = "S3"
  description = "Policy to allow the packagecloud AWS user access to the bucket that contains the DEB/RPM/etc packages"
  path        = "/"
  policy      = data.aws_iam_policy_document.s3.json
  tags        = var.aws_tags
}

resource "aws_iam_user_policy_attachment" "cloudfront" {
  user       = aws_iam_user.packagecloud.name
  policy_arn = aws_iam_policy.cloudfront.arn
}

resource "aws_iam_user_policy_attachment" "iam" {
  user       = aws_iam_user.packagecloud.name
  policy_arn = aws_iam_policy.iam.arn
}

resource "aws_iam_user_policy_attachment" "s3" {
  user       = aws_iam_user.packagecloud.name
  policy_arn = aws_iam_policy.s3.arn
}
