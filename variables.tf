# ---------------------------------------------------------------------------
# Global
# ---------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region all resources are created in."
  type        = string
  default     = "eu-west-2"
}

variable "name_prefix" {
  description = "Prefix applied to AWS-facing resource names and Name tags."
  type        = string
  default     = "mupando"
}

variable "environment" {
  description = "Environment tag applied to the load balancer."
  type        = string
  default     = "demo"
}

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "192.168.0.0/16"
}

variable "subnets" {
  description = <<-DESC
    Public subnets, keyed by AZ suffix. The keys "a", "b" and "c" are each
    consumed by a named subnet resource, so all three must be present.
  DESC
  type = map(object({
    cidr = string
    az   = string
  }))

  default = {
    a = { cidr = "192.168.192.0/18", az = "eu-west-2a" }
    b = { cidr = "192.168.64.0/18", az = "eu-west-2b" }
    c = { cidr = "192.168.128.0/18", az = "eu-west-2c" }
  }

  validation {
    condition     = alltrue([for k in ["a", "b", "c"] : contains(keys(var.subnets), k)])
    error_message = "subnets must define the keys \"a\", \"b\" and \"c\"."
  }
}

# ---------------------------------------------------------------------------
# Ports and ingress
# ---------------------------------------------------------------------------

variable "app_port" {
  description = "Port the instances serve on. Used by the instance SG, the target group and its health check."
  type        = number
  default     = 80
}

variable "alb_http_port" {
  description = "HTTP port the ALB listens on."
  type        = number
  default     = 80
}

variable "alb_https_port" {
  description = "HTTPS port opened on the ALB security group. No listener is bound to it yet."
  type        = number
  default     = 443
}

variable "alb_ingress_cidrs" {
  description = "CIDR blocks allowed to reach the ALB. Narrow this to trusted ranges for anything non-public."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ---------------------------------------------------------------------------
# Compute
# ---------------------------------------------------------------------------

variable "ami_id" {
  description = "AMI for the launch template. Region-specific; must match root_device_name below."
  type        = string
}

variable "ssh_public_key" {
  description = "OpenSSH public key registered as the EC2 key pair. Break-glass only; there is no SSH ingress."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the ASG."
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Name tag applied to instances launched by the ASG."
  type        = string
  default     = "cloud-web-server"
}

variable "root_device_name" {
  description = "Root block device name. \"/dev/xvda\" for Amazon Linux, \"/dev/sda1\" for Ubuntu."
  type        = string
  default     = "/dev/xvda"
}

variable "root_volume_size" {
  description = "Root volume size in GiB."
  type        = number
  default     = 8
}

variable "root_volume_type" {
  description = "Root volume type."
  type        = string
  default     = "gp3"
}

# ---------------------------------------------------------------------------
# Auto Scaling
# ---------------------------------------------------------------------------

variable "asg_min_size" {
  description = "Minimum number of instances in the ASG."
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of instances in the ASG."
  type        = number
  default     = 6
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in the ASG."
  type        = number
  default     = 2
}

variable "health_check_grace_period" {
  description = "Seconds to wait before health-checking a new instance. Must cover the user-data install."
  type        = number
  default     = 300
}

variable "instance_refresh_min_healthy_percentage" {
  description = "Percentage of the ASG that must stay healthy during a rolling instance refresh."
  type        = number
  default     = 50
}

variable "instance_refresh_warmup" {
  description = "Seconds a refreshed instance is given to warm up before counting as healthy."
  type        = number
  default     = 300
}

variable "cpu_target_value" {
  description = "Average CPU utilisation the target-tracking policy holds the group at."
  type        = number
  default     = 50
}

# ---------------------------------------------------------------------------
# Load balancer
# ---------------------------------------------------------------------------

variable "alb_name" {
  description = "Name of the ALB. Changing this replaces the load balancer."
  type        = string
  default     = "web-lb-tf"
}

variable "alb_deletion_protection" {
  description = "Whether to block `terraform destroy` from deleting the ALB."
  type        = bool
  default     = false
}

variable "target_group_health_check" {
  description = "Target group health check settings. The ASG's ELB health check type reads its verdict from these."
  type = object({
    path                = string
    matcher             = string
    interval            = number
    timeout             = number
    healthy_threshold   = number
    unhealthy_threshold = number
  })

  default = {
    path                = "/"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# ---------------------------------------------------------------------------
# S3
# ---------------------------------------------------------------------------

variable "app_bucket_prefix" {
  description = "Prefix for the generated application bucket name."
  type        = string
  default     = "mupandoprojectbucket-"
}

variable "logs_bucket_prefix" {
  description = "Prefix for the generated logs bucket name."
  type        = string
  default     = "mupandoprojectslogs-bucket-"
}

variable "bucket_force_destroy" {
  description = "Allow `terraform destroy` to delete non-empty buckets."
  type        = bool
  default     = true
}
