
# This Terraform configuration file sets up an AWS EC2 instance using the latest Amazon Linux 2023 AMI.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.56.0"
    }
  }
}





# Configure the AWS provider
provider "aws" {
  region = var.region
}





data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}




resource "aws_instance" "showcase" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  subnet_id = "subnet-0ee34b65d7ea49080"
 
  tags = {
    Name = "Terraform-Lab-Instance-dev"
  }
}


# resource "aws_instance" "web-1" {
#   ami           = data.aws_ami.amazon_linux_2023.id
#   instance_type = var.instance_type

#   tags = {
#     Name = "Terraform-Lab-Instance-test"
#   }
# }






# =================== S3 and DYnamoDb backend configuration ===================


# aws s3 bucket to store the terraform state file


resource "aws_s3_bucket" "s3-backend" {

  bucket = "file-layouts-terraform-bucket"
  lifecycle {
    prevent_destroy = true
  }

}


resource "aws_s3_bucket_versioning" "s3-bucket_ver" {
  bucket = aws_s3_bucket.s3-backend.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "name" {
  bucket = aws_s3_bucket.s3-backend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }


}


resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.s3-backend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


