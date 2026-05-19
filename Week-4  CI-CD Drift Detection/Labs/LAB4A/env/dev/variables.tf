variable "region" {
  type        = string
  default     = "us-east-1"
  description = " the region to deploy the infra"

}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "ec2 instance type"
}