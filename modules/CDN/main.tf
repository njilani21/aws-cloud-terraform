############################################
# CDN MODULE - CloudFront in front of the ALB
# Caches content at edge locations globally,
# terminates TLS at the edge, and absorbs
# traffic/DDoS load before it reaches the VPC.
# Uses CloudFront's default *.cloudfront.net
# domain and default certificate - no custom
# domain or ACM cert required, so this stays
# fully free (aside from CloudFront usage).
############################################

resource "aws_cloudfront_distribution" "app" {
  enabled     = true
  comment     = "${var.project_name} CDN"
  price_class = var.price_class

  origin {
    domain_name = var.alb_dns_name
    origin_id    = "alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" # ALB listener is HTTP; use "https-only" if you add an HTTPS listener
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true
      headers      = ["Host"]

      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 3600   # 1 hour - reasonable default for a mostly-static site
    max_ttl     = 86400  # 24 hours
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # CloudFront's own default certificate - covers *.cloudfront.net,
  # no ACM cert or custom domain needed. This is what keeps this
  # module completely free.
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "${var.project_name}-cdn"
  }
}
