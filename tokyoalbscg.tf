resource "aws_security_group" "tokyo_alb_sg" {
  name        = "tokyo-alb-sg"
  description = "Tokyo ALB security group"
  vpc_id      = aws_vpc.tokyovpc.id

  # Inbound HTTP (later restricted to CloudFront IP ranges)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound to app tier
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "tokyo-alb-sg" }
}
##################################
# Tokyo APP security group
##################################
resource "aws_security_group" "tokyo_app_sg" {
  name        = "tokyo-app-sg"
  description = "Tokyo application tier"
  vpc_id      = aws_vpc.tokyovpc.id

  # Only ALB can reach the app tier
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.tokyo_alb_sg.id]
  }

  # App needs outbound to RDS, SSM, Secrets Manager, etc.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "tokyo-app-sg" }
}

