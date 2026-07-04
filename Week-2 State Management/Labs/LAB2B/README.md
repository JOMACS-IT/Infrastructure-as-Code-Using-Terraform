# 🧪 LAB 2B: Managing Multiple Environments with Terraform State

In Lab 2A you configured a single remote backend for one environment. In the real world you usually need to manage **multiple environments** — `dev`, `staging`, `prod` — without mixing up their state files or accidentally applying dev changes to production.

This lab walks through the two most common ways Terraform practitioners solve that problem:

1. **File Layout separation** — a separate directory (and separate backend/state file) per environment.
2. **Workspaces** — a single configuration, with Terraform automatically keeping a separate state file per named workspace.

You'll build both, compare them, and see the trade-offs of each.

## 🧰 Prerequisites
- AWS account
- AWS CLI installed and configured (`aws configure`)
- Terraform installed (`terraform -v`) — version 1.10+ recommended (this lab uses S3 native state locking via `use_lockfile`, no DynamoDB table required)
- Completion of Lab 2A (remote state basics)

## 📁 Project Structure

```bash
LAB2B/
├── file-layout/
│   └── environment/
│       ├── dev/
│       │   ├── main.tf
│       │   ├── variabes.tf
│       │   ├── outputs.tf
│       │   └── backend.tf
│       ├── staging/
│       │   ├── main.tf
│       │   ├── variabes.tf
│       │   ├── outputs.tf
│       │   └── backend.tf
│       └── prod/
│           ├── main.tf
│           ├── variabes.tf
│           ├── outputs.tf
│           └── backend.tf
└── workspaces/
    ├── main.tf
    ├── variabes.tf
    ├── outputs.tf
    └── backend.tf
```

---

## Part 1: File Layout — One Directory, One Backend, Per Environment

The idea here is simple: each environment gets its **own folder**, its own `main.tf`, and its own `backend.tf` pointing at its own S3 bucket and state key. There's no way to accidentally run `dev` config against `prod` state, because they're physically separate configurations.

### Step 1: Inspect the `dev` environment

Open `file-layout/environment/dev/main.tf`. It provisions the same EC2 instance pattern as before, tagged `Terraform-Lab-Instance-dev`, and also creates its **own** S3 bucket dedicated to dev state:

```bash
resource "aws_s3_bucket" "s3-backend" {
  bucket = "s3-state-backend-terraform-env-dev-lab-101"
  lifecycle {
    prevent_destroy = true
  }
}
```

Now open `file-layout/environment/dev/backend.tf`. Unlike Lab 2A, notice this backend is **already active** (not commented out), and it uses the newer S3 **native locking** feature instead of a DynamoDB table:

```bash
terraform {
  backend "s3" {
    bucket       = "s3-state-backend-terraform-env-dev-lab-101"
    key          = "file-layouts/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

`use_lockfile = true` tells Terraform to write a lock file directly inside the S3 bucket during operations — this is a newer alternative to the DynamoDB-based locking you used in Lab 2A.

### Step 2: Deploy the `dev` environment

```bash
cd file-layout/environment/dev
terraform init
terraform plan
terraform apply
```

> ⚠️ S3 bucket names must be globally unique. If `s3-state-backend-terraform-env-dev-lab-101` is taken, rename it in both `main.tf` and `backend.tf` before continuing.

### Step 3: Deploy the `staging` environment

Open `file-layout/environment/staging/backend.tf` — it's also already active, pointing at its own bucket:

```bash
terraform {
  backend "s3" {
    bucket       = "s3-state-backend-terraform-staging-lab-101"
    key          = "workspace-example/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

Deploy it the same way, in its own terminal/directory:

```bash
cd file-layout/environment/staging
terraform init
terraform plan
terraform apply
```

Notice in `staging/main.tf` the instance resource is named `web-staging` and tagged `Terraform-Lab-Instance-staging` — a completely separate resource from dev's `web`.

### Step 4: Wire up the `prod` environment yourself

Open `file-layout/environment/prod/backend.tf`. This time the backend block is **commented out**:

```bash
# terraform {
#   backend "s3" {
#     bucket         = "s3-state-backend-terraform-lab-101"
#     key            = "workspace-example/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     use_lockfile = true
#   }
# }
```

As an exercise, uncomment it and update the `bucket` to match the bucket `prod/main.tf` actually creates (`s3-state-backend-terraform-prod-lab-101`), and give it its own unique `key`, for example `env/prod/terraform.tfstate`. This mirrors what you practiced with the local-to-remote migration in Lab 2A.

Then deploy it:

```bash
cd file-layout/environment/prod
terraform init
terraform plan
terraform apply
```

### Step 5: Confirm isolation

List each bucket to confirm each environment's state is stored completely separately:

```bash
aws s3 ls s3://s3-state-backend-terraform-env-dev-lab-101/file-layouts/
aws s3 ls s3://s3-state-backend-terraform-staging-lab-101/workspace-example/
aws s3 ls s3://s3-state-backend-terraform-prod-lab-101/env/prod/
```

Each environment has its own state file, its own lock, and its own lifecycle — a change in `dev` can never affect `staging` or `prod` state.

---

## Part 2: Workspaces — One Configuration, Multiple States

The file-layout approach works, but it means maintaining nearly-duplicate `.tf` files per environment. **Terraform workspaces** offer an alternative: keep a *single* configuration, and let Terraform automatically keep a separate state file per named workspace inside the same backend.

### Step 6: Inspect the workspaces configuration

Open `workspaces/main.tf`. It defines one EC2 instance resource, `web-1`. The S3 bucket resources you saw earlier are **commented out here** — this configuration assumes the backend bucket already exists (you'll create it manually).

Open `workspaces/backend.tf`:

```bash
terraform {
  backend "s3" {
    bucket       = "s3-state-backend-terraform-workspace-lab-101"
    key          = "workspace-example/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

### Step 7: Create the backend bucket manually

Since this configuration doesn't create its own bucket, create it yourself before initializing:

```bash
aws s3api create-bucket --bucket s3-state-backend-terraform-workspace-lab-101 --region us-east-1
aws s3api put-bucket-versioning --bucket s3-state-backend-terraform-workspace-lab-101 --versioning-configuration Status=Enabled
```

### Step 8: Initialize and create workspaces

```bash
cd workspaces
terraform init
```

By default you start in the `default` workspace. Create dedicated workspaces for each environment:

```bash
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod
```

List them at any time with:

```bash
terraform workspace list
```

### Step 9: Deploy into each workspace

Switch into a workspace with `terraform workspace select <name>`, then plan/apply as usual. Each workspace gets its own isolated state, even though it's the exact same `main.tf`:

```bash
terraform workspace select dev
terraform apply

terraform workspace select staging
terraform apply

terraform workspace select prod
terraform apply
```

### Step 10: See how Terraform stores each workspace's state

Behind the scenes, Terraform namespaces each workspace's state under a fixed prefix inside the same bucket/key:

```bash
aws s3 ls s3://s3-state-backend-terraform-workspace-lab-101/env:/dev/workspace-example/
aws s3 ls s3://s3-state-backend-terraform-workspace-lab-101/env:/staging/workspace-example/
aws s3 ls s3://s3-state-backend-terraform-workspace-lab-101/env:/prod/workspace-example/
```

Three separate `terraform.tfstate` objects, one config.

### Step 11: Clean up

Destroy each workspace's resources before deleting the bucket:

```bash
terraform workspace select dev
terraform destroy

terraform workspace select staging
terraform destroy

terraform workspace select prod
terraform destroy
```

Then remove the leftover workspaces and bucket:

```bash
terraform workspace select default
terraform workspace delete dev
terraform workspace delete staging
terraform workspace delete prod

aws s3 rm s3://s3-state-backend-terraform-workspace-lab-101 --recursive
aws s3api delete-bucket --bucket s3-state-backend-terraform-workspace-lab-101
```

Also tear down the file-layout environments (dev, staging, prod), emptying and deleting each bucket the same way you did in Lab 2A, since each has `prevent_destroy` set on its bucket and versioning enabled.

## ✅ File Layout vs. Workspaces — When to Use Which

| | File Layout | Workspaces |
|---|---|---|
| Config duplication | Higher — separate files per env | None — one config for all envs |
| Risk of drift between envs | Lower (explicit per-env files) | Higher (easy to forget env-specific differences) |
| Blast radius if you run the wrong command | Contained to one directory | Easy to `apply` against the wrong workspace by mistake |
| Good for | Environments with real structural differences (different regions, instance counts, modules) | Environments that are near-identical copies of the same infrastructure |

Most real-world Terraform codebases end up combining both ideas: workspaces (or a `.tfvars` file per environment) for lightweight variation, and a proper module structure once environments diverge enough to need it — which is exactly what you'll explore in Week 3.