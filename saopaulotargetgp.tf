resource "aws_lb_target_group" "saopaulo_app_tg" {
  
  name     = "saopaulo-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.liberdade_vpc01.id

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = "200"
  }

  tags = {
    Name = "saopaulo-app-tg"
  }
}

################################
# EC2 TARGET GROUP ATTACHMENT
#################################
# resource "aws_lb_target_group_attachment" "saopaulo_app_tg_attachment" {
  
  
#   target_group_arn = aws_lb_target_group.saopaulo_app_tg.arn
#   target_id        = aws_instance.saopaulo_app_instance.id
#   port             = 80
# }