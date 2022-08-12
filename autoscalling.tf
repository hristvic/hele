# Get AMZ Linux Ami
data "aws_ami" "linux_ami" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm*"]
  }
}

# Read user data config file for web servers
data "aws_region" "current" {}

data "template_file" "web-userdata" {
  template = file("userdata.tpl")
  vars = {
    region              = data.aws_region.current.name
    aws_efs_file_system = aws_efs_file_system.helestore.id
    rdshost             = aws_db_instance.db-instance.address

  }
}

# Setup launch config for Web Server Instances
resource "aws_launch_configuration" "as-config" {
  name_prefix          = "heleserver-"
  image_id             = data.aws_ami.linux_ami.id
  instance_type        = "t2.micro"
  key_name             = aws_key_pair.hele-auth.id
  security_groups      = [aws_security_group.instance-sg.id]
  user_data            = data.template_file.web-userdata.rendered
  iam_instance_profile = aws_iam_instance_profile.ec2-profile.name
  lifecycle {
    create_before_destroy = true
  }
}

# Setup AS Group Config
resource "aws_autoscaling_group" "as-group" {
  name                 = "autoscalling-group"
  launch_configuration = aws_launch_configuration.as-config.name
  min_size             = 2
  max_size             = 4
  desired_capacity     = 2
  target_group_arns    = [aws_lb_target_group.alb-tg.arn]
  vpc_zone_identifier  = [aws_subnet.private-sn-01.id, aws_subnet.private-sn-02.id]
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [target_group_arns]
  }

}
#Createa dynamic autoscale policy
resource "aws_autoscaling_policy" "ec2-policy" {
  autoscaling_group_name = aws_autoscaling_group.as-group.name
  name                   = "ec2-policy"
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_lb.ext-alb.arn_suffix}/${aws_lb_target_group.alb-tg.arn_suffix}"
    }
    target_value = 1
  }
}

## Optional - generate key pair for SSH access if needed
resource "aws_key_pair" "hele-auth" {
  key_name   = "helekey"
  public_key = file("~/.ssh/helekey.pub")
}
