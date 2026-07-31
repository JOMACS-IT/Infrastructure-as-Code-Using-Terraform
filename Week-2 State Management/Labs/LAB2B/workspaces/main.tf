
# This Terraform configuration file sets up an AWS EC2 instance using the latest Amazon Linux 2023 AMI.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.56.0"
    }
  }
}

# terraform {
#   backend "s3" {
#     bucket       = "modules-s3-terraform-bucket"
#     key          = "workspace-example/terraform.tfstate"
#     region       = "us-east-1"
#     encrypt      = true
#     use_lockfile = true

#   }
# }

provider "aws" {
  region = var.aws_region
}