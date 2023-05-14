module "kms" {
  source      = "github.com/massdriver-cloud/terraform-modules//aws/aws-kms-key?ref=afe781a"
  md_metadata = var.md_metadata
  policy      = data.aws_iam_policy_document.s3.json
}


data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "s3" {
  statement {
    sid = "Allow access to S3 for all principals in the account that are authorized to use S3"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "kms:ViaService"
      values   = ["s3.amazonaws.com", "s3.*.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid = "Allow administration of the key"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.bucket

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      kms_master_key_id = module.kms.key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  count  = var.monitoring.access_logging ? 1 : 0
  bucket = aws_s3_bucket.access_logs.0.bucket

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      kms_master_key_id = module.kms.key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}