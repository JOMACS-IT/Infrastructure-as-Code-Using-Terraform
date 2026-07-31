output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2_sg.id
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.main.public_ip
}




output "state_bucket_name" {
  description = "Name of the S3 bucket for remote state"
  value       = aws_s3_bucket.junior-terraform_states.bucket
}

output "state_bucket_arn" {
  description = "ARN of the S3 state bucket"
  value       = aws_s3_bucket.junior-terraform_states.arn
}

output "lock_table_name" {
  description = "Name of the DynamoDB lock table"
  value       = aws_dynamodb_table.terraform_lock.name
}

output "lock_table_arn" {
  description = "ARN of the DynamoDB lock table"
  value       = aws_dynamodb_table.terraform_lock.arn
}
