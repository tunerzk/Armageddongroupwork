

resource "aws_security_group" "saopaulo_alb_sg" {
  name     = "saopaulo-alb-sg"
  vpc_id   = aws_vpc.liberdade_vpc01.id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    # description     = "Allow HTTPS from CloudFront only" WAF restricted
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "saopaulo-alb-sg"
  }
}


#############################################
# Dedicated Security Group for ALB → EC2 communication
#############################################
resource "aws_security_group" "saopaulo_ec2_sg" {
  name        = "saopaulo-ec2-sg"
  description = "Allow ALB to reach EC2"
  vpc_id      = aws_vpc.liberdade_vpc01.id

  ingress {
    description = "Allow ALB to reach EC2"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # security_groups = [aws_security_group.saopaulo_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
 