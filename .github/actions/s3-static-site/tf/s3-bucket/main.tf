locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid       = "AdminAccess"
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${local.account_id}:root",
      ]
    }
  }

  statement {
    sid      = "PublicGetObject"
    actions  = ["s3:GetObject"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]
  }

  dynamic "statement" {
    for_each = length(var.read_access_entities) > 0 ? [1] : []
    content {
      sid       = "ReadAccess"
      actions   = [
        "s3:Get*",
        "s3:List*",
      ]
      resources = [
        aws_s3_bucket.this.arn,
        "${aws_s3_bucket.this.arn}/*"
      ]
      principals {
        type        = "AWS"
        identifiers = var.read_access_entities
      }
    }
  }
  
  dynamic "statement" {
    for_each = length(var.write_access_entities) > 0 ? [1] : []
    content {
      sid       = "WriteAccess"
      actions   = [
        "s3:Put*",
        "s3:Delete*",
      ]
      resources = [
        aws_s3_bucket.this.arn,
        "${aws_s3_bucket.this.arn}/*"
      ]
      principals {
        type        = "AWS"
        identifiers = var.write_access_entities
      }
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}
