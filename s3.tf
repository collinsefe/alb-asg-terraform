# # This file contains the configuration for creating EC2 instances

resource "aws_s3_bucket" "foo" {
  bucket_prefix = "mupandoprojectbucket-"
  force_destroy = true
}

resource "aws_s3_bucket" "logs" {
  bucket_prefix = "mupandoprojectslogs-bucket-"
  force_destroy = true
}


resource "aws_s3_bucket_public_access_block" "foo" {
  bucket                  = aws_s3_bucket.foo.id
  ignore_public_acls      = true
  restrict_public_buckets = true
  block_public_policy     = true
  block_public_acls       = true
}

resource "aws_s3_bucket_public_access_block" "logging" {
  bucket                  = aws_s3_bucket.logs.id
  ignore_public_acls      = true
  restrict_public_buckets = true
  block_public_policy     = true
  block_public_acls       = true
}

