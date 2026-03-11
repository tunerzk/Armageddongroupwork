resource "aws_lb" "tokyo_alb" {
  name               = "tokyo-app-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.tokyo_alb_sg.id]
  subnets            = [
    aws_subnet.tokyo_public_a.id,
    aws_subnet.tokyo_public_b.id
  ]

  tags = { Name = "tokyo-app-alb" }
}
