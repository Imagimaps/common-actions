data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_route53_zone" "root" {
  name         = var.root_domain
  private_zone = false
}

data "aws_acm_certificate" "domain_cert" {
  provider    = aws.us_east_1
  domain      = var.fq_domain_name
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

data "aws_s3_bucket" "origin" {
  bucket = var.fq_domain_name
}

data "aws_lb" "services" {
  tags = {
    Environment = var.environment
    Project     = var.project
  }
}
