resource "aws_wafv2_web_acl" "saopaulo_waf" {
  name        = "saopaulo-waf"
  description = "waf for saopaulo ALB"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "allow-cloudfront"
    priority = 1

    action {
      block{}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.cloudfront_ips.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "allow-cloudfront"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "saopaulo-waf"
    sampled_requests_enabled   = true
  }
}

###########################################
# WAF IP Set for CloudFront 
###########################################
data "aws_ip_ranges" "cloudfront" {
  services = ["CLOUDFRONT"]
}

resource "aws_wafv2_ip_set" "cloudfront_ips" {
  name               = "cloudfront-ip-set"
  description        = "CloudFront IP ranges"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = data.aws_ip_ranges.cloudfront.cidr_blocks
}

resource "aws_wafv2_web_acl_association" "saopaulo_alb_waf_assoc" {
  resource_arn = aws_lb.saopaulo_alb.arn
  web_acl_arn  = aws_wafv2_web_acl.saopaulo_waf.arn
}


