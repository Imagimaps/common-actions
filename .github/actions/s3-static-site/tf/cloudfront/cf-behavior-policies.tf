resource "aws_cloudfront_cache_policy" "images" {
  name        = "images-cache-policy"
  comment     = "Cache policy for images"
  default_ttl = 28800 # 8 hours
  max_ttl     = 86400 # 1 day
  min_ttl     = 3600  # 1 hour

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
      cookies {
        items = []
      }
    }
    headers_config {
      header_behavior = "none"
      headers {
        items = []
      }
    }
    query_strings_config {
      query_string_behavior = "none"
      query_strings {
        items = []
      }
    }
  }
}

resource "aws_cloudfront_origin_request_policy" "images" {
  name    = "images-origin-request-policy"
  comment = "Origin request policy for images"
  cookies_config {
    cookie_behavior = "all"
    cookies {
      items = []
    }
  }
  headers_config {
    header_behavior = "allViewer"
    headers {
      items = []
    }
  }
  query_strings_config {
    query_string_behavior = "none"
    query_strings {
      items = []
    }
  }
}

# WebSocket specific policies
resource "aws_cloudfront_origin_request_policy" "websockets" {
  name    = "websockets-origin-request-policy"
  comment = "Origin request policy for WebSocket connections"
  cookies_config {
    cookie_behavior = "all"
    cookies {
      items = []
    }
  }
  headers_config {
    header_behavior = "whitelist"
    headers {
      items = [
        "Sec-WebSocket-Key",
        "Sec-WebSocket-Version",
        "Sec-WebSocket-Protocol",
        "Sec-WebSocket-Accept",
        "Sec-WebSocket-Extensions",
        "Upgrade",
        "Connection"
      ]
    }
  }
  query_strings_config {
    query_string_behavior = "all"
    query_strings {
      items = []
    }
  }
}
