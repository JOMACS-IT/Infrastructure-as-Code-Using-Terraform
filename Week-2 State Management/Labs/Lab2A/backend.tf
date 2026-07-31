terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.56.0"
    }
  }

  required_version = ">= 1.3.0"

  # Add this backend block after the S3 bucket and DynamoDB table exist
  backend "s3" {
    bucket       = "junior-terraform-state-bucket" # must match var.state_bucket_name
    key          = "Lab2A/terraform.tfstate"       # path inside the bucket
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = "true" # must match var.lock_table_name
  }
}

provider "aws" {
  region = var.aws_region
}
