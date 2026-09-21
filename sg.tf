# Internet-facing security group for the ALB. This is the only thing the public
# is allowed to talk to.
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-security-group"
  description = "Allows inbound HTTP/HTTPS traffic from the internet to the ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix} ALB Security Group"
  }

  ingress {
    description = "Allow HTTP Traffic"
    from_port   = var.alb_http_port
    to_port     = var.alb_http_port
    protocol    = "tcp"
    cidr_blocks = var.alb_ingress_cidrs
  }

  ingress {
    description = "Allow HTTPS Traffic"
    from_port   = var.alb_https_port
    to_port     = var.alb_https_port
    protocol    = "tcp"
    cidr_blocks = var.alb_ingress_cidrs
  }

  egress {
    description = "Allow All outbound Traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instance security group. Reachable on the app port only from the ALB, so the
# instances cannot be hit directly even though they sit in public subnets. No
# SSH ingress: shell access goes through SSM Session Manager, see iam.tf.
resource "aws_security_group" "instance" {
  name        = "${var.name_prefix}-instance-security-group"
  description = "Allows HTTP traffic from the ALB only"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix} Instance Security Group"
  }

  ingress {
    description     = "Allow HTTP Traffic from the ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow All outbound Traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
