resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "S3AccessControlStaticContent"
  description                       = "Access Control Policy for S3 Origin"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = data.aws_s3_bucket.origin.bucket_regional_domain_name
    origin_id   = var.fq_domain_name

    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }

  comment         = "CDN for public static content in env ${var.environment}"
  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"
  
  default_root_object = "index.html"

  aliases = [var.fq_domain_name]

  default_cache_behavior {
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.fq_domain_name

    cache_policy_id = aws_cloudfront_cache_policy.images.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.images.id

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront_logs.bucket_domain_name
  }

  tags = {
    Environment = var.environment
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = data.aws_acm_certificate.domain_cert.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }
}
