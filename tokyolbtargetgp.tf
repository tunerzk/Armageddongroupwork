resource "aws_lb_target_group" "tokyo_app_tg" {
  name     = "tokyo-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.tokyovpc.id

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }

  tags = { Name = "tokyo-app-tg" }
}


##########################################
# APP TIER LISTENER
##########################################
resource "aws_lb_listener" "tokyo_alb_listener" {
  load_balancer_arn = aws_lb.tokyo_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tokyo_app_tg.arn
  }
}