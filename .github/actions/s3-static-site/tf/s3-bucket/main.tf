locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  acl    = "private"
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid       = "AdminAccess"
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
    condition {
      test     = "ForAllValues:StringLike"
      variable = "aws:userid"
      values   = [
        "arn:aws:sts::${local.account_id}:assumed-role/aws-reserved/sso.amazonaws.com/${local.region}/AWSReservedSSO_AWSAdministratorAccess*",
        "arn:aws:sts::${local.account_id}:assumed-role/aws-reserved/sso.amazonaws.com/${local.region}/AWSReservedSSO_AWSPowerUserAccess*",
      ]
    }
  }

  dynamic "statement" {
    for_each = var.read_access_entities.length > 0 ? toset(var.read_access_entities) : []
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
    for_each = var.write_access_entities.length > 0 ? toset(var.write_access_entities) : []
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
