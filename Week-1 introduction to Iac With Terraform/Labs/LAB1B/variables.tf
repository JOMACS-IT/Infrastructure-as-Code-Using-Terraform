

variable "aws_region" {
  type        = string
  description = "The target AWS region for deployment"
  default     = "eu-north-1"
}

variable "vpc_cidr" {
  type        = string
  description = "The base CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  description = "The CIDR block for the public subnet"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  type        = string
  description = "The CIDR block for the private subnet"
  default     = "10.0.2.0/24"
}

variable "instance_type" {
  type        = string
  description = "The Free Tier eligible size for the EC2 instance"
  default     = "t3.micro"
}