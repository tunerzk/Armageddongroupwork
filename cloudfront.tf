
provider "aws" {
  alias  = "useast1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "waf_global"
  region = "us-east-1"

  endpoints {
    wafv2 = "https://wafv2.us-east-1.amazonaws.com"
  }
}

provider "aws" {
  alias  = "saopaulo"
  region = "sa-east-1"
}


resource "aws_acm_certificate" "cloudfront_cert" {
  provider          = aws.useast1
  domain_name       = "armadawgs-growl.click"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Convert the SET into a LIST so we can index it
locals {
  cert_validation = tolist(aws_acm_certificate.cloudfront_cert.domain_validation_options)[0]
}

resource "aws_route53_record" "cloudfront_cert_validation" {
  zone_id = var.hosted_zone_id

  name    = local.cert_validation.resource_record_name
  type    = local.cert_validation.resource_record_type
  records = [local.cert_validation.resource_record_value]

  ttl = 60
}

resource "aws_acm_certificate_validation" "cloudfront_cert_validation_complete" {
  provider                = aws.useast1
  certificate_arn         = aws_acm_certificate.cloudfront_cert.arn
  validation_record_fqdns = [aws_route53_record.cloudfront_cert_validation.fqdn]
}


###################################################
# CLOUDFRONT DISTRIBUTION
###################################################
resource "aws_cloudfront_distribution" "global_app" {
  enabled             = true
  comment             = "Global distribution for armadawgs-growl.click"
  default_root_object = ""

  aliases = [
    "armadawgs-growl.click"
  ]

  origin {
    domain_name = "tokyo-app-alb-770507830.ap-northeast-1.elb.amazonaws.com"
    origin_id   = "tokyo-alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "tokyo-alb-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS"
    ]

    cached_methods = [
      "GET",
      "HEAD"
    ]

    cache_policy_id = data.aws_cloudfront_cache_policy.caching_optimized.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cloudfront_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  price_class = "PriceClass_100"
  web_acl_id = aws_wafv2_web_acl.cloudfront_waf.arn

  logging_config {
    include_cookies = false
    bucket          = "lab3-cloudfront-logs.s3.amazonaws.com"
    prefix          = "cloudfront-logs/"
  }
}



data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}





#############################
# cloudfront waf
###########################

resource "aws_wafv2_web_acl" "cloudfront_waf" {
  provider = aws.useast1
  name        = "cloudfront-waf"
  description = "WAF for CloudFront"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "AWS-AWSManagedRulesSQLiRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "sqli"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "cloudfront-waf"
    sampled_requests_enabled   = true
  }
}



