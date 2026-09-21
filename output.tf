# ---------------------------------------------------------------------------
# Load balancer — the entry point to the stack
# ---------------------------------------------------------------------------

output "alb_url" {
  description = "URL to open in a browser once the ASG instances pass their health checks."
  value       = "http://${aws_lb.main.dns_name}"
}

output "alb_dns_name" {
  description = "Public DNS name of the ALB."
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the ALB."
  value       = aws_lb.main.arn
}

output "alb_zone_id" {
  description = "Hosted zone ID of the ALB, for a Route 53 alias record."
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group the ASG registers into."
  value       = aws_lb_target_group.main.arn
}

# ---------------------------------------------------------------------------
# Auto Scaling
# ---------------------------------------------------------------------------

output "asg_name" {
  description = "Name of the Auto Scaling Group."
  value       = aws_autoscaling_group.main.name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group."
  value       = aws_autoscaling_group.main.arn
}

output "asg_capacity" {
  description = "Configured min / desired / max instance counts."
  value = {
    min     = aws_autoscaling_group.main.min_size
    desired = aws_autoscaling_group.main.desired_capacity
    max     = aws_autoscaling_group.main.max_size
  }
}

output "launch_template_id" {
  description = "ID of the launch template."
  value       = aws_launch_template.main.id
}

output "launch_template_version" {
  description = "Launch template version the ASG is pinned to."
  value       = aws_launch_template.main.latest_version
}

# The ASG launches instances itself, so Terraform never knows their IDs.
# These commands look them up at run time.
output "list_instances_command" {
  description = "AWS CLI command listing the instances currently in the ASG and their health."
  value       = "aws autoscaling describe-auto-scaling-groups --region ${var.aws_region} --auto-scaling-group-names ${aws_autoscaling_group.main.name} --query 'AutoScalingGroups[0].Instances[].[InstanceId,AvailabilityZone,LifecycleState,HealthStatus]' --output table"
}

output "target_health_command" {
  description = "AWS CLI command showing how the ALB sees each registered instance."
  value       = "aws elbv2 describe-target-health --region ${var.aws_region} --target-group-arn ${aws_lb_target_group.main.arn} --query 'TargetHealthDescriptions[].[Target.Id,TargetHealth.State,TargetHealth.Reason]' --output table"
}

output "ssm_session_command" {
  description = "Command to open a shell on an instance via SSM (replace INSTANCE_ID). There is no SSH ingress."
  value       = "aws ssm start-session --region ${var.aws_region} --target INSTANCE_ID"
}

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "Public subnet IDs, keyed by availability zone."
  value = {
    (aws_subnet.public.availability_zone) = aws_subnet.public.id
    (aws_subnet.foo.availability_zone)    = aws_subnet.foo.id
    (aws_subnet.bar.availability_zone)    = aws_subnet.bar.id
  }
}

output "internet_gateway_id" {
  description = "ID of the internet gateway."
  value       = aws_internet_gateway.gw.id
}

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = aws_route_table.public_rt.id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group."
  value       = aws_security_group.alb.id
}

output "instance_security_group_id" {
  description = "ID of the instance security group."
  value       = aws_security_group.instance.id
}

# ---------------------------------------------------------------------------
# IAM and access
# ---------------------------------------------------------------------------

output "instance_role_arn" {
  description = "ARN of the instance IAM role."
  value       = aws_iam_role.instance.arn
}

output "instance_profile_name" {
  description = "Name of the instance profile attached by the launch template."
  value       = aws_iam_instance_profile.instance.name
}

output "key_pair_name" {
  description = "Name of the EC2 key pair (break-glass only)."
  value       = aws_key_pair.this.key_name
}

# ---------------------------------------------------------------------------
# S3
# ---------------------------------------------------------------------------

output "app_bucket_name" {
  description = "Generated name of the application bucket."
  value       = aws_s3_bucket.foo.bucket
}

output "logs_bucket_name" {
  description = "Generated name of the logs bucket."
  value       = aws_s3_bucket.logs.bucket
}
