#launch template
resource "aws_launch_template" "main" {
  name_prefix   = "${var.name_prefix}-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.this.key_name
  user_data     = filebase64("${path.module}/user-data.sh")

  iam_instance_profile {
    name = aws_iam_instance_profile.instance.name
  }

  # Require IMDSv2 so a server-side request forgery bug in the app cannot read
  # the instance role's credentials.
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # Encrypt the root volume. root_device_name must match the AMI's root device:
  # "/dev/xvda" for Amazon Linux, "/dev/sda1" for Ubuntu.
  block_device_mappings {
    device_name = var.root_device_name

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      encrypted             = true
      delete_on_termination = true
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.instance.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.instance_name
    }
  }

}

# #auto scaling group
resource "aws_autoscaling_group" "main" {
  name                = "${var.name_prefix}-terraform-asg"
  vpc_zone_identifier = [aws_subnet.public.id, aws_subnet.foo.id, aws_subnet.bar.id]
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size

  # Replace an instance whose Apache is dead, not just one whose kernel has
  # stopped answering. The grace period covers the user-data install.
  health_check_type         = "ELB"
  health_check_grace_period = var.health_check_grace_period

  launch_template {
    id = aws_launch_template.main.id
    # Pinning the resolved version (rather than "$Latest") is what makes a
    # launch template edit show up as a diff on this resource, which is what
    # actually fires the instance refresh below.
    version = aws_launch_template.main.latest_version
  }

  # Roll the fleet onto the new launch template instead of leaving running
  # instances on the old one.
  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = var.instance_refresh_min_healthy_percentage
      instance_warmup        = var.instance_refresh_warmup
    }
  }
}

# Target tracking replaces the old pair of simple scale-up/scale-down policies
# and their CloudWatch alarms: AWS manages the alarms, and it will not thrash
# between the two thresholds the way a 60s cooldown did.
resource "aws_autoscaling_policy" "cpu" {
  name                   = "cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.main.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = var.cpu_target_value
  }
}
