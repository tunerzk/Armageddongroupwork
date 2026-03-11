resource "aws_autoscaling_group" "tokyo_app_asg" {
  name                = "tokyo-app-asg"
  max_size            = 3
  min_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = [
    aws_subnet.tokyo_private_a.id,
    aws_subnet.tokyo_private_b.id
  ]

  launch_template {
    id      = aws_launch_template.tokyo_app_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tokyo_app_tg.arn]

  tag {
    key                 = "Name"
    value               = "tokyo-app-ec2"
    propagate_at_launch = true
  }
}
