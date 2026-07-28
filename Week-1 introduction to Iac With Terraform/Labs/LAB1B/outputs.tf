output "vpc_id" {
  value       = aws_vpc.selorm_vpc.id
  description = "The ID of the created Virtual Private Cloud"
}

output "ec2_public_ip" {
  value       = aws_instance.my_ec2.public_ip
  description = "The public IP address to connect to your new EC2 instance via SSH"
}

output "security_group_id" {
  value       = aws_security_group.ec2_sg.id
  description = "The ID of the security group firewall attached to your instance"
}
