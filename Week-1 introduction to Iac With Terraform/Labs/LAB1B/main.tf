

# 1. Terraform Configuration Block (Defines the AWS provider version)
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.55.0"
    }
  }
}

# 2. Provider Block (Configures your target deployment region)
provider "aws" {
  region = var.aws_region
}

# 3. VPC Resource Block (Creates the isolated virtual network)
resource "aws_vpc" "selorm_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "Terraform-VPC"
  }
}

# 4. Internet Gateway Block (Allows public internet access to the VPC)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.selorm_vpc.id

  tags = {
    Name = "main-igw"
  }
}

# 5. Public Subnet Block (Hosts the EC2 instance)
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.selorm_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true # Automatically assigns a public IP to instances

  tags = {
    Name = "public-subnet"
  }
}

# 6. Private Subnet Block (Hosts isolated backend infrastructure)
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.selorm_vpc.id
  cidr_block = var.private_subnet_cidr

  tags = {
    Name = "private-subnet"
  }
}

# 7. Public Route Table Block (Directs outbound traffic to the Internet Gateway)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.selorm_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# 8. Private Route Table Block (Keeps traffic internal within the VPC)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.selorm_vpc.id

  # No open internet route route exists here, keeping it completely private

  tags = {
    Name = "private-route-table"
  }
}

# 9. Public Route Table Association Block (Links public subnet to public route table)
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 10. Private Route Table Association Block (Links private subnet to private route table)
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}


# 11. Security Group Block (Acts as a virtual firewall for your EC2 instance)
resource "aws_security_group" "ec2_sg" {
  name        = "allow_web_traffic"
  description = "Allow inbound SSH and HTTP traffic"
  vpc_id      = aws_vpc.selorm_vpc.id

  # Inbound Rule: Allow SSH (Port 22) from anywhere
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound Rule: Allow HTTP (Port 80) from anywhere
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Rule: Allow all outbound traffic from the instance
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-security-group"
  }
}


# 12. EC2 Instance Resource Block (Deploys the actual virtual server inside your public subnet)
resource "aws_instance" "my_ec2" {
  ami           = "ami-0aba19e56f3eaec05"
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "my-public-ec2-instance"
  }
}