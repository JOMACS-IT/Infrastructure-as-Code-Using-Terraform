# 🧪 LAB 2A: Configure and Use Terraform Remote State (S3 + DynamoDB)

In this lab you will move a Terraform project away from **local state** (a `terraform.tfstate` file sitting on your laptop) to **remote state**, stored in an Amazon S3 bucket and locked with a DynamoDB table.

You will provision an EC2 instance the same way you did in Lab 1A, but this time the lab also creates the S3 bucket and DynamoDB table that Terraform needs for remote state, and then you will reconfigure the backend so that all future state operations happen remotely instead of on your local disk.

By the end of this lab you will understand:
- Why local state is risky for teams
- How an S3 backend stores state remotely
- How a DynamoDB table provides state locking to prevent concurrent writes
- How to migrate existing local state into a remote backend

## 🧰 Prerequisites
- AWS account
- AWS CLI installed and configured (`aws configure`)
- Terraform installed (`terraform -v`)
- Completion of Lab 1A (basic `terraform init/plan/apply` workflow)

## 📁 Project Structure

```bash
Lab2A/
├── main.tf         # EC2 instance + S3 bucket + DynamoDB table for state
├── variabes.tf      # Input variables (region, instance_type)
├── outputs.tf       # Output values (instance IP and ID)
└── backend.tf       # Remote backend configuration (commented out initially)
```

## Step-by-Step Guide

### Step 1: Inspect the configuration

Open `main.tf`. Notice it defines two groups of resources:

1. **The EC2 instance** — the same web server you built in Lab 1A, using the latest Amazon Linux 2023 AMI.
2. **The remote state backend infrastructure** — an S3 bucket (with versioning, encryption, and public access blocked) and a DynamoDB table used for state locking:

```bash
resource "aws_s3_bucket" "s3-backend" {
  bucket = "s3-state-backend-terraform-lab-101"
}

resource "aws_s3_bucket_versioning" "s3-bucket_ver" {
  bucket = aws_s3_bucket.s3-backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "dynamodb_lock" {
  name         = "terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
```

> ⚠️ S3 bucket names are globally unique across **all** AWS accounts. If `s3-state-backend-terraform-lab-101` is already taken, rename it in `main.tf` (and later in `backend.tf`) before continuing.

Open `variabes.tf` and `outputs.tf` to confirm the region/instance type variables and the outputs you'll see after `apply`.

Open `backend.tf`. You'll see the remote backend block is **commented out** — this is intentional, and you'll enable it later in the lab:

```bash
# terraform {
#   backend "s3" {
#     bucket         = "s3-state-backend-terraform-lab-101"
#     key            = "env/prod/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-lock-table"
#   }
# }
```

### Step 2: Initialize Terraform (local state)

With the backend still commented out, Terraform will default to storing state **locally**.

```bash
terraform init
```

### Step 3: Plan and apply

```bash
terraform plan
terraform apply
```

Type `yes` when prompted. This creates:
- The EC2 instance
- The S3 bucket (with versioning, encryption, and public-access blocking enabled)
- The DynamoDB lock table

### Step 4: Inspect the local state file

After the apply completes, look in your project directory:

```bash
ls -la
cat terraform.tfstate
```

You'll see a `terraform.tfstate` file containing the full state of your infrastructure in JSON. This file lives only on your machine, which means:
- It can be lost or corrupted with no backup
- It can't safely be shared by a team
- Nothing prevents two people from running `apply` at the same time and corrupting the state

This is exactly the problem a remote backend solves.

### Step 5: Enable the remote backend

Now that the S3 bucket and DynamoDB table exist, open `backend.tf` and **uncomment** the backend block:

```bash
terraform {
  backend "s3" {
    bucket         = "s3-state-backend-terraform-lab-101"
    key            = "env/prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
  }
}
```

- `bucket` — the S3 bucket that will store the state file
- `key` — the path/filename of the state object inside the bucket
- `encrypt` — encrypts the state file at rest
- `dynamodb_table` — the table Terraform uses to acquire a lock during operations, preventing concurrent `apply` runs

### Step 6: Migrate local state to the remote backend

Re-run `init`. Terraform detects the backend configuration changed and offers to copy your existing local state into S3:

```bash
terraform init
```

You'll see a prompt similar to:

```
Initializing the backend...
Do you want to copy existing state to the new backend?
  Enter "yes" to copy and "no" to start with an empty state.

  Enter a value: yes
```

Type `yes`. Terraform uploads your local state to the S3 bucket.

### Step 7: Verify the remote state

Confirm the state file now lives in S3 instead of on disk:

```bash
aws s3 ls s3://s3-state-backend-terraform-lab-101/env/prod/
```

You should see a `terraform.tfstate` object. Your local `terraform.tfstate` is now just a thin pointer/backup file — the source of truth lives in S3.

### Step 8: Confirm state locking works

Run a plan or apply and, while it's running, check the DynamoDB table in another terminal:

```bash
aws dynamodb scan --table-name terraform-lock-table
```

While Terraform is applying, you'll briefly see a lock item appear with your operation's ID — this is what prevents a second `terraform apply` from running against the same state at the same time. If you try to run `terraform apply` concurrently in a second terminal, it will fail with a "state locked" error until the first operation finishes.

### Step 9: Make a change and confirm remote state updates

Try changing `instance_type` in `variabes.tf`, then:

```bash
terraform plan
terraform apply
```

Re-check the S3 object — it will have a new version if you inspect the bucket's versioning tab, confirming every state change is tracked remotely.

### Step 10: Clean up

Because this lab manages the S3 bucket and DynamoDB table with the **same** Terraform configuration that uses them as a backend, you can't simply `destroy` everything in one shot — Terraform can't delete the bucket that's actively storing its own state.

To tear everything down safely:

1. Comment the `backend "s3"` block back out in `backend.tf`.
2. Re-run `terraform init` and choose to copy the state back to local when prompted.
3. Empty the S3 bucket (required before Terraform can delete it, since it has versioning enabled):
   ```bash
   aws s3 rm s3://s3-state-backend-terraform-lab-101 --recursive
   ```
4. Destroy everything, including the EC2 instance, S3 bucket, and DynamoDB table:
   ```bash
   terraform destroy
   ```

> 💡 In real-world projects, the S3 bucket and DynamoDB table are usually created **once**, in a separate "bootstrap" configuration, rather than in the same project that uses them as a backend. This lab combines them in one file purely to make the cause-and-effect of remote state easier to see.

## ✅ What You Learned

- Local `terraform.tfstate` has no locking and no durability guarantees
- An S3 backend centralizes state so a team can share it
- A DynamoDB table provides locking so concurrent runs don't corrupt state
- `terraform init` handles migrating state from one backend to another