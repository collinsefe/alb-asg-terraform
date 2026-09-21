# Copy to terraform.tfvars and adjust. Only ami_id and ssh_public_key are
# required; everything else falls back to the defaults in variables.tf.

# --- Required ---------------------------------------------------------------

# Region-specific. Must match root_device_name below.
ami_id = "ami-00710ab5544b60cf7"

ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC56JQgYBYnirYqIDoWxcvkuXfAJ895uY0ULLfFcvgBy5zCwm8G9jYq+NyrHloorJHSMgKEbLlTUA5XKaqYD7nlM1FSTyb4W8I3e1+FO0apbRlXe2B3u0yRlNq3x2hFGJlKJwUczEtW1yOwW/WERPccHW3KSkuOhYwZ1r9uhLJF0wLaNQVfY3H6kk5M22/1x7G+MDokq2nDbYWBmaBwUlABcN0bSsqTRwn4OlXH3oZeEkhlik1fAMcScYtZCbPglExlNSjZvMY3kBTfOtq6RaMUHzTCdW0Z8nwsXmxL74si7tSMh4mc+EN9ykjt/e5ClgkPmZG8+GiASOgfBa9rDpYeWnZ3CQ3O7b7YvThUZ2vMbRvbhH0DjgsDKcbE+ONiW4vBmpQHED9QEyAa22s68odaYSvKuhrwy1ZQC5yQnc5UMttmrzSBwMxOeAHz4ibmGUEDQgQcZ+t9qZwnCfFKw2JCL8JgQOw9J8oHfKa3buUnGNLyogK38s2qdq1WfMEVO2c= collinsefe@yahoo.com"

# --- Common overrides -------------------------------------------------------

aws_region  = "eu-west-2"
name_prefix = "mupando"
environment = "demo"

vpc_cidr = "192.168.0.0/16"

subnets = {
  a = { cidr = "192.168.192.0/18", az = "eu-west-2a" }
  b = { cidr = "192.168.64.0/18", az = "eu-west-2b" }
  c = { cidr = "192.168.128.0/18", az = "eu-west-2c" }
}

instance_type        = "t2.micro"
asg_min_size         = 2
asg_desired_capacity = 2
asg_max_size         = 6
cpu_target_value     = 50

# Narrow this for anything that is not meant to be public.
alb_ingress_cidrs = ["0.0.0.0/0"]
