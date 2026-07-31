# ─── VPC ───────────────────────────────────────────────────────────────────────

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

# ─── Internet Gateway ──────────────────────────────────────────────────────────

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}

# ─── Public Subnets ────────────────────────────────────────────────────────────

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_name}-public-subnet-${count.index + 1}"
    Project = var.project_name
    Tier    = "public"
  }
}

# ─── Private Subnets ───────────────────────────────────────────────────────────

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]

  tags = {
    Name    = "${var.project_name}-private-subnet-${count.index + 1}"
    Project = var.project_name
    Tier    = "private"
  }
}

# ─── Public Route Table ────────────────────────────────────────────────────────

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "${var.project_name}-public-rt"
    Project = var.project_name
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ─── Security Group ────────────────────────────────────────────────────────────

resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Security group for the EC2 instance"
  vpc_id      = aws_vpc.main.id

  # Allow SSH from a specified CIDR
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # Allow HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-ec2-sg"
    Project = var.project_name
  }
}

# ─── EC2 Instance ──────────────────────────────────────────────────────────────

resource "aws_instance" "main" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name    = "${var.project_name}-ec2"
    Project = var.project_name
  }
}


# ─── S3 Bucket for Remote State ───────────────────────────────────────────────

resource "aws_s3_bucket" "junior-terraform_states" {
  bucket = var.state_bucket_name

  # Prevent accidental deletion of state bucket
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name    = var.state_bucket_name
    Project = var.project_name
    Purpose = "terraform-remote-states"
  }
}

# Enable versioning so you can recover previous state files
resource "aws_s3_bucket_versioning" "terraform_states" {
  bucket = aws_s3_bucket.junior-terraform_states.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt state files at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.junior-terraform_states.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access to the state bucket
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.junior-terraform_states.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ─── DynamoDB Table for State Locking ─────────────────────────────────────────

resource "aws_dynamodb_table" "terraform_lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"

  # Required attribute for Terraform state locking
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  # Protect lock table from accidental deletion
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name    = var.lock_table_name
    Project = var.project_name
    Purpose = "terraform-state-lock"
  }
}
