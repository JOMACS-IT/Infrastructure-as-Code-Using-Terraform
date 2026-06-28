output "instance_public_ip" {
  value = aws_instance.web_server_hardcoded.public_ip
}

output "instance_id" {
  value = aws_instance.web_server_hardcoded.id
}

output "instance_public_ip_using_data_source" {
  value = aws_instance.web_server_using_data_source.public_ip
}

output "instance_id_using_data_source" {
  value = aws_instance.web_server_using_data_source.id
}