resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "OAI for ${var.s3_bucket_id}"
}

resource "aws_s3_bucket_policy" "this" {
  bucket = var.s3_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.this.id}" }
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${var.s3_bucket_id}/*"
      }
    ]
  })
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for ${var.s3_bucket_id}"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  origin {
    domain_name = var.s3_bucket_regional_domain_name
    origin_id   = var.s3_bucket_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.s3_bucket_id
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = var.tags
}
