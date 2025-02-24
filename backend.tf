terraform {
  backend "s3" {
    bucket = "mupandoprojects-terraformstate-bucket"
    key    = "demo/infra.tfstate"
    region = "eu-west-2"
  }
}
