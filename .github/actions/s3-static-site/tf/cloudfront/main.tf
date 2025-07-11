resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "S3AccessControl"
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
  origin {
    domain_name = "api-alb.${var.fq_domain_name}"
    origin_id   = "services-${var.environment}-alb"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  comment         = "CDN for website ${var.fq_domain_name} in project ${var.project} ${var.environment}"
  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"
  
  default_root_object = "index.html"

  # Include the primary domain and all additional domains in the aliases
  aliases = concat([var.fq_domain_name], var.additional_domain_names)

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }
  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }
  custom_error_response {
    error_code            = 503
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }
  custom_error_response {
    error_code            = 504
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  default_cache_behavior {
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.fq_domain_name

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  ordered_cache_behavior {
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["GET", "HEAD"]
    path_pattern     = "/api/*"
    target_origin_id = "services-${var.environment}-alb"

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "allow-all"
  }
  
  ordered_cache_behavior {
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["GET", "HEAD"]
    path_pattern     = "/api/*.png"
    target_origin_id = "services-${var.environment}-alb"

    cache_policy_id = aws_cloudfront_cache_policy.images.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.images.id

    viewer_protocol_policy = "allow-all"
  }
  
  # WebSocket cache behavior
  dynamic "ordered_cache_behavior" {
    for_each = var.enable_websockets ? [1] : []
    content {
      path_pattern     = var.websocket_path_pattern
      allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
      cached_methods   = ["GET", "HEAD"]
      target_origin_id = "websocket-${var.environment}"
      
      # Use the WebSocket specific origin request policy
      origin_request_policy_id = aws_cloudfront_origin_request_policy.websockets.id
      
      # Don't cache WebSocket connections
      forwarded_values {
        query_string = true
        headers      = ["*"]

        cookies {
          forward = "all"
        }
      }
      
      # Allow all protocols for WebSockets
      viewer_protocol_policy = "allow-all"
      
      # Set appropriate TTLs for WebSocket connections
      min_ttl     = 0
      default_ttl = 0  # Don't cache WebSocket connections
      max_ttl     = 0
    }
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
