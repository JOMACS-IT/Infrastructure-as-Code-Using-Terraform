
variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "ec2 instance type"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "the environment to deploy the infra"
  
}