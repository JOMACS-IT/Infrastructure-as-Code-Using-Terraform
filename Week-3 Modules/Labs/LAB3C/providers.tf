
# This Terraform configuration file sets up an AWS EC2 instance using the latest Amazon Linux 2023 AMI.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}





# Configure the AWS provider
provider "aws" {
  region = var.region
}