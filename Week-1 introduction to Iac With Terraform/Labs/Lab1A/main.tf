

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.52.0"
    }
  }
}



provider "aws" {
  region = var.region
  
}



resource "aws_instance" "my_ec2" {
  ami           = var.ec2_ami
  instance_type = var.instance_type
  tags = {
    Name = "MyEC2Instance"
  }

}




