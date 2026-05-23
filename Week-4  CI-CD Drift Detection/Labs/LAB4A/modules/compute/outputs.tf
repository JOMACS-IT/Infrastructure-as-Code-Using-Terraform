output "ec2-instance-public-ip" {
  value = aws_instance.web.public_ip
}



output "ec2-instance-id" {
    value = aws_instance.web.id
  
}


