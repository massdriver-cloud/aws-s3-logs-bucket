resource "aws_s3_bucket" "main" {
  bucket        = var.md_metadata.name_prefix
  force_destroy = false
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.main.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "main" {
  bucket     = aws_s3_bucket.main.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.main]
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}

resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count  = length(var.lifecycle_settings.transition_rules) > 0 || var.lifecycle_settings.expire ? 1 : 0
  bucket = aws_s3_bucket.main.id

  rule {
    id = "lifecycle"

    status = "Enabled"

    dynamic "expiration" {
      for_each = var.lifecycle_settings.expire ? ["true"] : []
      content {
        days = lookup(var.lifecycle_settings, "expiration_days", null)
      }
    }

    dynamic "transition" {
      for_each = { for rule in var.lifecycle_settings.transition_rules : rule.storage_class => rule }
      content {
        storage_class = transition.value.storage_class
        days          = transition.value.days
      }
    }
  }
}

// Access Logging
resource "aws_s3_bucket" "access_logs" {
  count  = var.monitoring.access_logging ? 1 : 0
  bucket = "${var.md_metadata.name_prefix}-logging"
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "access_logs" {
  count  = var.monitoring.access_logging ? 1 : 0
  bucket = aws_s3_bucket.access_logs.0.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "access_logs" {
  count      = var.monitoring.access_logging ? 1 : 0
  bucket     = aws_s3_bucket.access_logs.0.id
  acl        = "log-delivery-write"
  depends_on = [aws_s3_bucket_ownership_controls.access_logs]
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  count  = var.monitoring.access_logging ? 1 : 0
  bucket = aws_s3_bucket.access_logs.0.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}

resource "aws_s3_bucket_logging" "main" {
  count  = var.monitoring.access_logging ? 1 : 0
  bucket = aws_s3_bucket.main.id

  target_bucket = aws_s3_bucket.access_logs.0.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
  count  = var.monitoring.access_logging ? 1 : 0
  bucket = aws_s3_bucket.access_logs.0.id

  rule {
    id = "lifecycle"

    status = "Enabled"

    transition {
      days          = 7
      storage_class = "INTELLIGENT_TIERING"
    }
  }
}
