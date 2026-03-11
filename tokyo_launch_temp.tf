resource "aws_launch_template" "tokyo_app_lt" {
  name_prefix   = "tokyo-app-lt-"
  image_id      = "ami-0f9ae750e8274075b" # Amazon Linux 2 in ap-northeast-1
  instance_type = "t3.micro"

  network_interfaces {
    security_groups = [aws_security_group.tokyo_app_sg.id]
    subnet_id       = aws_subnet.tokyo_private_a.id
  }

  iam_instance_profile {
  name = aws_iam_instance_profile.tokyo_ec2_instance_profile.name
}


  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl enable httpd
    systemctl start httpd
    echo "Tokyo app tier is alive" > /var/www/html/index.html
    echo "OK" > /var/www/html/health
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "tokyo-app-ec2"
    }
  }
}
