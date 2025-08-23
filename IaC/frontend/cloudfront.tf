resource "aws_cloudfront_distribution" "frontend_cdn" {
  enabled             = true
  default_root_object = "index.html"

  aliases = ["mytraderdeck.com"]

  # Frontend Origin (S3)
  origin {
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id   = "S3Frontend"
    
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.s3_oai.cloudfront_access_identity_path
    }
  }

  # Backend API Origin (ALB)
  origin {
    domain_name = aws_lb.internal_alb.dns_name
    origin_id   = "ALBBackend"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1.2"]

      # Max allowed by CloudFront (cannot exceed 60)
      origin_read_timeout      = 60
      origin_keepalive_timeout = 60
    }
  }

  # Ticker Logos Origin (S3)
  origin {
    domain_name = data.aws_s3_bucket.ticker_icons.bucket_regional_domain_name
    origin_id   = "S3Logos"

    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }

  # Default Cache Behavior - Serves React App
  default_cache_behavior {
    target_origin_id       = "S3Frontend"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]

    min_ttl                = 0
    default_ttl            = 30   # 30 seconds (for near real-time updates)
    max_ttl                = 300  # 5 mins (as a fallback)
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  # Cache Behavior for Static Assets (CSS, JS, Images)
  ordered_cache_behavior {
    path_pattern           = "/static/*"
    target_origin_id       = "S3Frontend"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    min_ttl                = 86400   # 1 Day
    default_ttl            = 604800  # 1 Week
    max_ttl                = 31536000  # 1 Year
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  # Cache Behavior for API Requests
  ordered_cache_behavior {
    path_pattern           = "/api/*"
    target_origin_id       = "ALBBackend"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]

    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6"  
    origin_request_policy_id = aws_cloudfront_origin_request_policy.api_origin_policy.id 
  }

  # Cache Behavior for Ticker Logos (Cache Forever)
  ordered_cache_behavior {
    path_pattern           = "/logos/*"
    target_origin_id       = "S3Logos"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    min_ttl                = 315360000
    default_ttl            = 315360000
    max_ttl                = 315360000
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  
  # Redirect 403 and 404 errors to index.html
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:676206948384:certificate/ecd94cd8-abfe-40df-a65a-fc5694483558"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

resource "aws_cloudfront_origin_request_policy" "api_origin_policy" {
  name = "api-origin-policy"

  headers_config {
    header_behavior = "allViewer"
  }

  query_strings_config {
    query_string_behavior = "all"
  }

  cookies_config {
    cookie_behavior = "all" 
  }
}


data "aws_s3_bucket" "ticker_icons" {
  bucket = "td-ticker-icons"
}


output "cloudfront_url" {
  value       = aws_cloudfront_distribution.frontend_cdn.domain_name
  description = "CloudFront Distribution URL"
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.frontend_cdn.id
}


