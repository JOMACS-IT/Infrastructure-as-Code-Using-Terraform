data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}




resource "aws_instance" "web-server" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  tags = {
    Name = "Terraform-Lab-Instance"
  }
}





# Rename a resource in state | `terraform state mv` 




# Rename a resource declaratively  `moved` block 


# moved {
#   from = aws_instance.web
#   to   = aws_instance.web-server
# }




# Adopt an existing resource into Terraform  `terraform import` 


# import {
#   to = aws_s3_bucket.legacy
#   id = "using-terrafrom-import"
# }


# resource "aws_s3_bucket" "legacy" {
#   bucket = "using-terrafrom-import"
# }



#    to remove from state. The resource will not be destroyed, but Terraform will no longer manage it.

# removed {
#   from = aws_s3_bucket.legacy

#   lifecycle {
#     destroy = false # false = keep the real resource; true = destroy it
#   }
# }



#    to remove from state and destroy the real resource. This is a more aggressive approach, as it will delete the actual resource in addition to removing it from state.

# removed {
#   from = aws_s3_bucket.legacy
#   lifecycle { destroy = true }
# }