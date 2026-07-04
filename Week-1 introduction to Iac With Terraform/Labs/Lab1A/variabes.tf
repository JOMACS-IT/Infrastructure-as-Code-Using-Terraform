
variable "region" {
  type        = string
  default     = "us-east-1"
  description = "The AWS region where resources will be created."

}

variable "ec2_ami" {
  type        = string
  default     = "ami-08f44e8eca9095668"
  description = "The AMI ID for the EC2 instance."
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "The instance type for the EC2 instance."

}