
# This Terraform configuration file sets up an AWS EC2 instance 

/* 
THE TERRAFORM BLOCK
This first block specifies the required provider and its version. In this case, we are using the AWS provider from HashiCorp.
 you can read more about the terraform block here: https://developer.hashicorp.com/terraform/language/block/terraform
 */

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


/*
THE PROVIDER BLOCK
This block configures the AWS provider with the specified region. The region is defined as a variable, 
allowing for flexibility in deployment across different AWS regions.
you can read more about the provider block here: https://developer.hashicorp.com/terraform/language/block/provider

*/
provider "aws" {
  region = var.region
}





# creating an ec2 instance with hardcoded ami id

# THE RESOURCE BLOCK

/* 
 The resource block defines the AWS EC2 instance resource. It specifies the AMI ID, instance type, and tags for the instance.
 The AMI ID is hardcoded to a specific Amazon Linux 2023 AMI, 
 while the instance type is defined as a variable, allowing for flexibility in choosing different instance types.

  
*/




resource "aws_instance" "web_server_hardcoded" {
  ami           = "ami-08f44e8eca9095668" # Hardcoded AMI ID for Amazon Linux 2023*
  instance_type = var.instance_type

  tags = {
    Name = "Web-Server-Hardcoded"
  }
}







# Using the AWS AMI Data Source to fetch the latest Amazon Linux 2023 AMI

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}


resource "aws_instance" "web_server_using_data_source" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  tags = {
    Name = "Web-Server-Using-Data-Source"
  }
}