bucket         = "mupandoprojects-terraformstate-bucket"
key            = "demo/infra.tfstate"
region         = "eu-west-2"
encrypt        = true
dynamodb_table = "mupando-terraform-state-lock"
