resource "aws_s3_bucket" "cloudfront_logs" {
  bucket        = "${var.fq_domain_name}-cf-logs"
  force_destroy = true
}

// Set ACL for CloudFront log delivery
