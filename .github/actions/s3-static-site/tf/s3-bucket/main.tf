locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# resource "aws_s3_bucket_website_configuration" "this" {
#   bucket = aws_s3_bucket.this.id

#   index_document {
#     suffix = "index.html"
#   }

#   error_document {
#     key = "index.html"
#   }
# }

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

  statement {
    sid      = "CloudFrontAccess"
    actions  = ["s3:GetObject"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]
    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudfront::${local.account_id}:distribution/*"]
    }
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

# resource "aws_s3_bucket_policy" "this" {
#   bucket = aws_s3_bucket.this.id
#   policy = data.aws_iam_policy_document.bucket_policy.json
# }

# This is the current manually set policy on S3 Static Website bucket
# {
#     "Version": "2012-10-17",
#     "Id": "PolicyForCloudFrontPrivateContent",
#     "Statement": [
#         {
#             "Sid": "Admin",
#             "Effect": "Deny",
#             "Principal": "*",
#             "Action": "s3:*",
#             "Resource": [
#                 "arn:aws:s3:::dev.imagimaps.com/*",
#                 "arn:aws:s3:::dev.imagimaps.com"
#             ],
#             "Condition": {
#                 "StringNotLike": {
#                     "AWS:userId": "${local.account_id}",
#                     "AWS:PrincipalArn": [
#                         "arn:aws:sts::${local.account_id}:assumed-role/*",
#                         "arn:aws:iam::${local.account_id}:role/*"
#                     ],
#                     "AWS:SourceArn": "arn:aws:cloudfront::${local.account_id}:distribution/*"
#                 }
#             }
#         },
#         {
#             "Sid": "AllowCloudFrontServicePrincipal",
#             "Effect": "Allow",
#             "Principal": {
#                 "Service": "cloudfront.amazonaws.com"
#             },
#             "Action": "s3:GetObject",
#             "Resource": "arn:aws:s3:::dev.imagimaps.com/*",
#             "Condition": {
#                 "StringLike": {
#                     "AWS:SourceArn": "arn:aws:cloudfront::${local.account_id}:distribution/*"
#                 }
#             }
#         }
#     ]
# }
