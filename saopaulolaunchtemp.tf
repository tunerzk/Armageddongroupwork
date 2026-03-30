resource "aws_launch_template" "saopaulo_app_lt_new" {
  
  name_prefix   = "sp-lt-new-"
  image_id      = "ami-025f404fafb21297b"
  instance_type = "t3.micro"
  user_data     = base64encode(file("${path.module}/user_data.sh")) 
  
  metadata_options {
  http_tokens = "optional"
}
vpc_security_group_ids = [
  aws_security_group.saopaulo_ec2_sg.id
]



  iam_instance_profile {
  name = aws_iam_instance_profile.saopaulo_ec2_profile.name
}


  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "saopaulo-app-ec2"
    }
  }
}