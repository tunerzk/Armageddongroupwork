resource "aws_lb" "saopaulo_alb" {
  
  
  name               = "saopaulo-app-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.saopaulo_alb_sg.id]

  subnets = [
    aws_subnet.liberdade_public_subnet01.id,
    aws_subnet.liberdade_public_subnet02.id
  ]

  tags = {
    Name = "saopaulo-app-alb"
  }
}

resource "aws_lb_listener" "saopaulo_https_listener" {
  
  
  load_balancer_arn = aws_lb.saopaulo_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.saopaulo_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.saopaulo_app_tg.arn
  }
    depends_on = [
    aws_acm_certificate_validation.saopaulo_cert_validation_complete
  ]
  }



resource "aws_lb_listener" "saopaulo_http_listener" {
  
  
  load_balancer_arn = aws_lb.saopaulo_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "redirect"

    redirect {
      protocol   = "HTTPS"
      port       = 443
      status_code = "HTTP_301"
    }
  }
}
##########################################
# ACM CERTIFICATE
##########################################

resource "aws_acm_certificate" "saopaulo_cert" {
  provider           = aws.saopaulo
  domain_name        = "armadawgs-growl.click"
  validation_method  = "DNS"
  
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_route53_record" "saopaulo_cert_validation" {
  for_each = {for dvo in aws_acm_certificate.saopaulo_cert.domain_validation_options :
   dvo.domain_name => dvo}
  provider = aws.saopaulo
  zone_id = aws_route53_zone.main.zone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  records = [each.value.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "saopaulo_cert_validation_complete" {
  provider                = aws.saopaulo
  certificate_arn         = aws_acm_certificate.saopaulo_cert.arn
  validation_record_fqdns = [
    for record in aws_route53_record.saopaulo_cert_validation : record.fqdn
  ]
}


################################################
# ALB CERTIFICATE SA-EAST-1 (N. Virginia) → SA-EAST-1 (Sao Paulo)
################################################