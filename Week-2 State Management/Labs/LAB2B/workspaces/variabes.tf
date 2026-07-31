variable "aws_region" {
  type        = string
  description = "The target AWS deployment region"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "Base CIDR block for the VPC"
  default     = "10.0.0.0/16"
}
