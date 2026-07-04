# 📝 Week 2 Assignment: Remote State & Environment Separation

## Overview

In Lab 2A you configured a single remote backend (S3 + state locking). In Lab 2B you compared two strategies for managing multiple environments: **file layout** and **workspaces**. This assignment asks you to combine both skills into one project: you will build a properly isolated **three-environment** infrastructure setup, backed by remote state, and demonstrate that your setup is safe for team use.

There is no starter code for this assignment — you are expected to write your own Terraform configuration from scratch, using Lab 2A and Lab 2B as your reference.

## 🎯 Learning Objectives

By completing this assignment you will be able to:
- Configure an S3 remote backend with state locking from scratch
- Migrate a project from local state to remote state
- Isolate `dev`, `staging`, and `prod` state so that no environment can accidentally affect another
- Explain, in your own words, the trade-offs between file-layout separation and workspaces
- Safely tear down infrastructure that manages its own state backend

## 🧰 Prerequisites

- AWS account with programmatic access configured (`aws configure`)
- Terraform installed, version 1.10 or later (`terraform -v`)
- Completion of Lab 2A and Lab 2B

---

## Part 1 — Build the Base Configuration (25 points)

Create a new Terraform project called `week2-assignment/` that provisions:

1. An `aws_instance` resource using the latest Amazon Linux 2023 AMI (reuse the `data "aws_ami"` pattern from the labs)
2. Two input variables: `region` (default `us-east-1`) and `instance_type` (default `t2.micro`)
3. Two outputs: the instance's public IP and instance ID
4. A `tags.Name` value that includes the environment name (e.g. `week2-assignment-dev`) — you'll parameterize this in Part 2

Confirm it works with local state before moving on:

```bash
terraform init
terraform plan
terraform apply
```

## Part 2 — Add Your Own Remote Backend (25 points)

Unlike the labs, you must **create your backend resources yourself** rather than starting from a provided `main.tf`.

1. Write the Terraform resources needed to create:
   - An S3 bucket for state storage (with versioning enabled, encryption enabled, and public access blocked)
   - State locking — you may use either the DynamoDB approach from Lab 2A **or** the `use_lockfile` native S3 locking approach from Lab 2B. In your `answers.md` (see Part 5), state which one you chose and why.
2. Apply this configuration with local state first, so the bucket (and DynamoDB table, if used) actually exist.
3. Write a `backend.tf` referencing the bucket you just created, then run `terraform init` to migrate your local state into it.
4. Confirm in the AWS Console or CLI that your state file now lives in S3.

> ⚠️ Remember the chicken-and-egg problem from Lab 2A: you cannot destroy a bucket that is actively storing the state that describes it. Keep this in mind for Part 4.

## Part 3 — Isolate Three Environments (30 points)

Using **one** of the two strategies from Lab 2B, produce a working `dev`, `staging`, and `prod` setup:

**Option A — File layout**
- Create `environment/dev/`, `environment/staging/`, `environment/prod/` directories
- Each has its own `main.tf`, `variabes.tf`, `outputs.tf`, and `backend.tf`
- Each points at a distinct S3 bucket and/or distinct state key so the three state files never collide

**Option B — Workspaces**
- Keep a single configuration
- Create `dev`, `staging`, and `prod` workspaces with `terraform workspace new`
- Use `terraform.workspace` inside your `.tf` files to vary the `Name` tag per environment (e.g. `"week2-assignment-${terraform.workspace}"`)

Whichever option you choose, you must be able to demonstrate that changing `dev` never touches `staging` or `prod` state.

Deploy all three environments.

## Part 4 — Prove It Works (10 points)

Produce evidence (terminal output, screenshots, or a short recording — your instructor will specify the format) showing:

1. `terraform state list` (or equivalent) run against **each** of the three environments, showing different resources/state per environment
2. The S3 bucket(s) containing separate state file(s) — via `aws s3 ls`
3. A locking mechanism in action: start an `apply` in one terminal and, in a second terminal, attempt to run `apply`/`plan` against the **same** environment at the same time. Capture the lock error.
4. A clean teardown of all three environments and the backend resources, in the correct order (see the chicken-and-egg note above)

## Part 5 — Written Reflection (10 points)

In a short `answers.md` (200–400 words), answer:

1. Which state-locking mechanism did you choose in Part 2 (DynamoDB or `use_lockfile`), and why?
2. Which environment-isolation strategy did you choose in Part 3 (file layout or workspaces)? What was one thing that was easier with your choice, and one thing that would have been easier with the other?
3. Describe, in your own words, what could go wrong on a team project if two engineers ran `terraform apply` at the same time against local state with no locking. How did your setup prevent this?
4. What order did you tear things down in, and why couldn't you do it in one single `terraform destroy`?

---

## 📦 Submission

Submit a link to a GitHub repository (or a zip file, per your instructor's preference) containing:

```
week2-assignment/
├── (your .tf files — either flat, or split into environment/ subfolders)
├── answers.md
└── evidence/          # screenshots or terminal logs from Part 4
```

**Do not commit your `.terraform/` directory, `terraform.tfstate` files, or AWS credentials.** Add a `.gitignore` that excludes them.

## ✅ Grading Rubric

| Criteria | Points |
|---|---|
| Base configuration provisions correctly | 25 |
| Remote backend created and state migrated successfully | 25 |
| Three environments isolated and independently deployable | 30 |
| Evidence of state isolation, locking, and clean teardown | 10 |
| Written reflection | 10 |
| **Total** | **100** |

## 💡 Tips

- Bucket names are global across all AWS accounts — pick unique names (e.g. include your name or student ID)
- If you get stuck migrating state, re-read Lab 2A Step 6 — the `terraform init` migration prompt is the key step
- Always run `terraform plan` before `apply` when working across multiple environments, so you catch a wrong-environment mistake before it happens
- Clean up your AWS resources promptly after grading to avoid unnecessary charges