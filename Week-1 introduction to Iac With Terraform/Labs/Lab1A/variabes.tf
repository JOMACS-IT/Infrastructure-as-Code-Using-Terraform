
variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-north-1"

}



variable "ec2_ami" {
  description = "The AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0ac1f955d6e62f3f1"
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = "t3.micro"
}