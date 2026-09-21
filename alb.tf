resource "aws_lb" "main" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public.id, aws_subnet.foo.id, aws_subnet.bar.id]

  enable_deletion_protection = var.alb_deletion_protection

  tags = {
    Environment = var.environment
  }
}


resource "aws_lb_target_group" "main" {
  name     = "${var.name_prefix}-lb-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  # Stated explicitly rather than relying on the defaults, since the ASG now
  # uses these results to decide whether to replace an instance.
  health_check {
    enabled             = true
    path                = var.target_group_health_check.path
    protocol            = "HTTP"
    matcher             = var.target_group_health_check.matcher
    interval            = var.target_group_health_check.interval
    timeout             = var.target_group_health_check.timeout
    healthy_threshold   = var.target_group_health_check.healthy_threshold
    unhealthy_threshold = var.target_group_health_check.unhealthy_threshold
  }
}


# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "example" {
  autoscaling_group_name = aws_autoscaling_group.main.id
  lb_target_group_arn    = aws_lb_target_group.main.arn
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.alb_http_port
  protocol          = "HTTP"
  #   ssl_policy        = "ELBSecurityPolicy-2016-08"
  #   certificate_arn   = "arn:aws:iam::123456789012:server-certificate/demo_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
