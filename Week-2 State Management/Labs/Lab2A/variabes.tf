variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the 2 public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the 4 private subnets"
  type        = list(string)
  default = [
    "10.0.3.0/24",
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24"
  ]
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0c02fb55956c7d316" # Amazon Linux 2 (us-east-1)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the EC2 instance"
  type        = string
  default     = "0.0.0.0/0" # Restrict this in production
}

variable "project_name" {
  description = "Project name used for resource tagging"
  type        = string
  default     = "my-project"
}



# variable "aws_region" {
#   description = "AWS region"
#   type        = string
#   default     = "us-east-1"
# }

# variable "project_name" {
#   description = "Project name used for tagging"
#   type        = string
#   default     = "my-project"
# }

variable "state_bucket_name" {
  description = "Globally unique name for the S3 state bucket"
  type        = string
  default     = "junior-terraform-state-bucket" # must be globally unique
}

variable "lock_table_name" {
  description = "Name for the DynamoDB lock table"
  type        = string
  default     = "my-project-terraform-lock"
}
