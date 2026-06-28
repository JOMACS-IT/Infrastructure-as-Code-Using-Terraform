# 🧪 LAB: Provision an EC2 Instance with Terraform

In this first lab exercise we will use Terraform an IaC tool  to create a virtual server, an EC2 instance called web  on AWS. 
We will write all the Terraform configuration files that define and deploy cloud infrastructure instead of creating resources manually through the AWS console.
Lets get started. 

## 🧰 Prerequisites
-- AWS account
-- AWS CLI installed and configured (aws configure)
-- Terraform installed (terraform -v)
-- Basic understanding of Linux terminal

## Step-by-Step Guide



### Step 1: Create Project Structure
Start by creating the folder structure for this lab 
```bash
mkdir terraform-ec2-lab
cd terraform-ec2-lab
touch main.tf variables.tf outputs.tf
```
The basic directory stucture should look like this
```bash
terraform-ec2-lab/
├── main.tf
├── variables.tf
└── outputs.tf
```

### Step 2: Configure Provider

In your main.tf file add this configuration. This configuration specifies that Terraform should use the AWS provider from HashiCorp (version 5.x) and configure it to deploy resources in the region defined in the region variable.

```bash
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}
```



### 🧩 Step 3: Define Variables

In your variables.tf  file, define two input variables,  region (defaulting to us-east-1) and  EC2 instance type (defaulting to t2.micro).

```bash
variable "region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}
```

### Step 4: Fetch Latest Amazon Linux 2023 AMI

Define a data source in your main.tf file. This configuration uses a data source in Terraform to automatically retrieve the most recent Amazon Linux 2023 AMI from Amazon Web Services by filtering for official images matching the specified name pattern.

```bash
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}
```

### Step 5: Create EC2 Instance

Now define your EC2 instance in the main.tf file. The configuration below creates an EC2 instance  using the latest Amazon Linux 2023 AMI and a specified instance type, while assigning it a name tag called Terraform-Lab-Instance.

```bash
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  tags = {
    Name = "Terraform-Lab-Instance"
  }
}
```
In your outputs.tf file define these outputs
###  Step 6: Define Outputs

In your outputs.tf file define these outputs.  This outputs will display the EC2 instance’s public IP address and instance ID after deployment.

```bash
output "instance_public_ip" {
  value = aws_instance.web.public_ip
}

output "instance_id" {
  value = aws_instance.web.id
}
```

---
By following the Terraform workflow, you have defined your configuration files to create your infrastructure. In the next steps, you will continue with the remaining stages in Terraform’s workflow: initialization, plan, apply, and destroy.
 

### Step 7: Initialize Terraform
```bash
terraform init
```

##  Step 8: Plan 

```bash
terraform plan
```

## Step 9: Apply Configuration

```bash
terraform apply
```
Type `yes` when prompted
Wait for your infrastructure to be provisioned

## Step 10: Verify Output
You should see:
1. The Instance ID
2. The instance Public IP address


## Step 11: Destroy Resources
Don't forget to cleans up the resources created to avoid charges
```bash
terraform destroy
```