# Terraform AWS Auto Scaling Deployment

## Overview
This Terraform project provisions an AWS environment including:
- A **VPC** with a public subnet
- An **Internet Gateway** for public access
- A **Security Group** allowing HTTP (80) and SSH (22) traffic
- A **Launch Template** defining EC2 instance configurations
- An **Auto Scaling Group** for automatic scaling of EC2 instances
- Scaling policies to automatically increase or decrease instances based on demand
- A **User Data Script** that installs Apache and displays the EC2 instance's IP in `index.html`

## Prerequisites
Ensure you have the following installed:
- [Terraform](https://www.terraform.io/downloads)
- [AWS CLI](https://aws.amazon.com/cli/)
- An **AWS account** with appropriate IAM permissions
- An **SSH key pair** in AWS (update `key_name` in `main.tf` accordingly)

## File Structure
```
.
├── main.tf           # Terraform configuration for VPC, Security Group, ASG, etc.
├── user-data.sh      # User data script for configuring Apache on EC2 instances
├── README.md         # Documentation
```

## Setup & Deployment
1. **Clone the repository**
   ```sh
   git clone https://github.com/yourusername/terraform-aws-autoscaling.git
   cd terraform-aws-autoscaling
   ```

2. **Initialize Terraform**
   ```sh
   terraform init
   ```

3. **Preview the changes**
   ```sh
   terraform plan
   ```

4. **Deploy the infrastructure**
   ```sh
   terraform apply -auto-approve
   ```

5. **Retrieve the Auto Scaling Group details**
   ```sh
   aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[*].Instances[*].InstanceId'
   ```

## Scaling Policies
The Auto Scaling Group is configured with two policies:
- **Scale Up**: Adds an instance when demand increases.
- **Scale Down**: Removes an instance when demand decreases.

## Cleanup
To remove all resources created by Terraform:
```sh
terraform destroy -auto-approve
```

## Notes
- Update the **AMI ID** in `main.tf` to match your AWS region.
- Modify the **availability zone** if needed.
- Ensure your AWS credentials are configured (`aws configure`).

## License
This project is open-source and available under the MIT License.

