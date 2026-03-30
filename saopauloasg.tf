resource "aws_autoscaling_group" "saopaulo_app_asg" {
  
  
  name             = "saopaulo-app-asg"
  max_size         = 3
  min_size         = 1
  desired_capacity = 1

  vpc_zone_identifier = [
    aws_subnet.liberdade_private_subnet01.id
  ]

launch_template {
  id      = aws_launch_template.saopaulo_app_lt_new.id
  version = "$Latest"
}


  target_group_arns = [
    aws_lb_target_group.saopaulo_app_tg.arn
  ]

  tag {
    key                 = "Name"
    value               = "saopaulo-app-ec2"
    propagate_at_launch = true
  }
}
