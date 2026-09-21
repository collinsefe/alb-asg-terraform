terraform {
  # Values supplied by backend.hcl:
  #   terraform init -backend-config=backend.hcl
  backend "s3" {}
}
