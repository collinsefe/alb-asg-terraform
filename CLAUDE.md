# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A single flat Terraform **root module** (no child modules, no `main.tf`) that deploys an
ALB + Auto Scaling Group web stack in `eu-west-2`. It is a learning/demo project. Configuration
lives in `variables.tf` (defaults) and `terraform.tfvars` (overrides); `output.tf` (singular)
exposes the ALB URL, resource IDs, and ready-to-run CLI commands — `terraform output` after apply.

This directory is its own git repository (`github.com/collinsefe/alb-asg-terraform`). It lives
inside the larger `aws-devops-repo` notes repo but is not tracked by it — commit and push from
here, not from the parent.

## Commands

Run everything from the repo root — `asg.tf` reads `user-data.sh` via a **relative** path, so a
different working directory breaks `plan`/`apply`.

```sh
terraform init -backend-config=backend.hcl
terraform fmt         # the tree is currently fmt-clean; keep it that way
terraform validate
terraform plan
terraform apply
terraform destroy
```

`terraform init` **must** be passed `-backend-config=backend.hcl`. `backend.tf` holds an empty
`backend "s3" {}` block because backend configuration is resolved before variables exist and
therefore cannot be interpolated; a plain `terraform init` will prompt interactively for the
bucket and key instead.

Deploys go to account 493245399435 via the `default` AWS profile. The other local profiles
(`collinsefe-admin`, `collins-workload`) are different accounts — don't set `AWS_PROFILE` to them.
The state bucket is shared with other projects (`ec2-scheduler/`, `terminate-untagged-instances/`);
only touch `demo/`.

There are no tests, no linter config, and no CI. `terraform validate` + `terraform plan` are the
only feedback loop. `validate` requires `init` to have succeeded, which requires backend access —
if you only need syntax checking without AWS credentials, `terraform fmt -check -recursive` works
offline.

Local tooling in use: Terraform **v1.5.7**, AWS CLI v2, AWS provider `~> 5.0`. There is no
`required_version` constraint, so newer Terraform will silently rewrite state — pin it before
upgrading.

## Architecture

One file per concern; resources are named `main` when there is exactly one per concern, and
AWS-facing names carry a `mupando-` prefix.

- `provider.tf` — region `eu-west-2`, provider `~> 5.0`.
- `variables.tf` — every tunable value, grouped by concern. Defaults reproduce the current
  deployment exactly, so a `plan` with no tfvars is a no-op against existing state.
- `terraform.tfvars` — overrides, committed (it holds no secrets: AMI ID, SSH *public* key, CIDRs).
  Never put credentials in it. `terraform.tfvars.example` mirrors it; keep the two in sync when
  adding a variable.
- `backend.tf` + `backend.hcl` — empty `backend "s3" {}` block plus its partial configuration:
  bucket `terraform-state-493245399435` (account 493245399435, the `default` AWS profile), key `demo/infra.tfstate`, encrypted, locked via
  the DynamoDB table `terraform-sept-2026`. **That table must exist before
  `terraform init`** — it is deliberately not managed here (the backend needs it before there is
  any state to manage it in). Create it with a `LockID` string partition key.
- `vpc.tf` — VPC `192.168.0.0/16` plus three /18 subnets, one per AZ, named `aws_subnet.public`
  (2a), `.foo` (2b), `.bar` (2c). The `.foo`/`.bar` names are historical; all three are used
  identically as the ASG's and ALB's subnet set.
- `sg.tf` — two security groups. `aws_security_group.alb` takes 80/443 from the internet;
  `aws_security_group.instance` accepts :80 **only from the ALB SG**. There is no SSH ingress.
- `iam.tf` — instance role + profile carrying `AmazonSSMManagedInstanceCore`. Shell access is via
  `aws ssm start-session`, not SSH; the key pair stays attached only as break-glass.
- `asg.tf` — launch template (hardcoded AMI, `t2.micro`, IMDSv2 required, encrypted gp3 root,
  `user-data.sh` via `filebase64`) → ASG across all three subnets (`min 2 / desired 2 / max 6`,
  `health_check_type = "ELB"`, rolling `instance_refresh`) → a single target-tracking policy at
  50% average CPU. The ASG pins `version = aws_launch_template.main.latest_version` rather than
  `"$Latest"` on purpose: with `"$Latest"` the ASG resource shows no diff when the launch template
  changes, so the instance refresh never fires.
- `alb.tf` — ALB + target group (port 80, explicit `health_check`) + HTTP :80 listener, joined to
  the ASG via `aws_autoscaling_attachment` rather than the ASG's `target_group_arns`. The target
  group's health check is what the ASG's `ELB` health check type reads from.
- `s3.tf` — two `bucket_prefix` buckets (app + logs), both with public access fully blocked and
  `force_destroy = true`. Neither is wired to anything yet; the "logs" bucket receives no ALB
  access logs.
- `key-pair.tf` — `aws_key_pair.this` with an inline public key, named `mupando-app-key`.
- `user-data.sh` — yum-installs Apache, enables it, writes an `index.html` showing `hostname -I`.
- `ec2.tf` — entirely commented out; a standalone instance kept for reference. It references
  `aws_security_group.web`, which no longer exists, so it cannot be uncommented as-is.

## Remaining known gaps

The blockers that used to prevent this stack from serving traffic (missing internet gateway,
mismatched key pair name, zero desired capacity) are fixed. What is still rough:

- **`var.ami_id` is a required input** rather than a lookup, so it is region-locked and ages out.
  Replace it with the AL2023 SSM parameter when convenient. `var.root_device_name` must be kept
  consistent with whatever AMI is chosen.
- **The three AZs and subnets are three copy-pasted resources** driven by keys `a`/`b`/`c` of
  `var.subnets`, rather than a single `for_each`. Collapsing them would change resource addresses
  and require `terraform state mv`.
- **`aws_s3_bucket.logs` is unused** — nothing writes to it and the ALB has no `access_logs` block.
- **No HTTPS.** The listener is plain :80; the ALB SG opens 443 but nothing listens on it.
- **`ec2.tf` is entirely commented out** and references `aws_security_group.web`, which does not
  exist, so it cannot be uncommented as-is.
- **No `required_version`**, so a newer Terraform will silently upgrade state.

## README drift

`README.md` predates the current layout: it references a `main.tf` that does not exist, describes
a single public subnet, and claims the internet gateway is created. Trust the `.tf` files over the
README.
