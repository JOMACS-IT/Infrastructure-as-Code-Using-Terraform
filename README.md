# Infrastructure as Code Using Terraform

![Terraform](https://img.shields.io/badge/Terraform-1.7+-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI%2FCD-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)
![HCL](https://img.shields.io/badge/Language-HCL-7B42BC?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

A structured, hands-on learning programme for provisioning and managing AWS infrastructure using Terraform — from foundational concepts through to production-grade CI/CD pipelines with automated security scanning, drift detection, and AI-assisted plan reviews.

---

## Table of Contents

- [Overview](#overview)
- [Programme Structure](#programme-structure)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Week-by-Week Guide](#week-by-week-guide)
- [CI/CD Pipeline](#cicd-pipeline)
- [Security Tooling](#security-tooling)
- [Folder Structure](#folder-structure)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

This repository is a four-week guided learning programme that takes you from writing your first Terraform resource block to running a fully automated, secure CI/CD pipeline on GitHub Actions. Each week builds on the last, introducing progressively advanced concepts with real AWS infrastructure examples.

By the end of the programme you will be able to:

- Write, validate, and apply production-quality Terraform configurations
- Manage Terraform state securely using remote backends on S3
- Build reusable, versioned Terraform modules
- Set up a GitHub Actions pipeline with automated linting, security scanning, plan review, manual approval gates, and drift detection
- Integrate AI agents into your pipeline to review plans and summarise security findings

---

## Programme Structure

```
Infrastructure-as-Code-Using-Terraform/
│
├── Week-1 introduction to Iac With Terraform/   # Core Terraform concepts
├── Week-2 State Management/                     # Remote state and locking
├── Week-3 Modules/                              # Reusable module patterns
├── Week-4 CI-CD Drift Detection/                # GitHub Actions pipeline + drift
│
├── .github/workflows/                           # All CI/CD workflow definitions
├── Books/                                       # Reference reading material
├── .gitignore
└── README.md
```

---

## Prerequisites

Before starting, make sure you have the following installed and configured:

| Tool | Version | Purpose |
|---|---|---|
| [Terraform](https://developer.hashicorp.com/terraform/install) | >= 1.7.0 | Core IaC tool |
| [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) | >= 2.0 | Authenticate to AWS |
| [TFLint](https://github.com/terraform-linters/tflint) | latest | Terraform linter |
| [Checkov](https://www.checkov.io) | latest | Security scanner |
| [Gitleaks](https://github.com/gitleaks/gitleaks) | latest | Secret scanner |
| [pre-commit](https://pre-commit.com) | latest | Local git hooks |
| [terraform-docs](https://terraform-docs.io) | latest | Auto-generate docs |
| Git | >= 2.0 | Version control |

**AWS Account setup:**

```bash
aws configure
# AWS Access Key ID:     <your-key>
# AWS Secret Access Key: <your-secret>
# Default region:        us-east-2
# Default output format: json
```

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/kodcapsule/Infrastructure-as-Code-Using-Terraform.git
cd Infrastructure-as-Code-Using-Terraform
```

### 2. Install pre-commit hooks

```bash
pip install pre-commit checkov
pre-commit install
pre-commit install --hook-type pre-push
```

### 3. Verify your tools

```bash
terraform version
tflint --version
checkov --version
gitleaks version
```

### 4. Start with Week 1

```bash
cd "Week-1 introduction to Iac With Terraform"
terraform init
terraform plan
terraform apply
```

---

## Week-by-Week Guide

### Week 1 — Introduction to IaC with Terraform

**Concepts covered:**
- What is Infrastructure as Code and why it matters
- Terraform core workflow: `init` → `plan` → `apply` → `destroy`
- HCL syntax: resources, variables, outputs, data sources, locals
- Provider configuration (AWS)
- Terraform state basics

**What you build:** Core AWS infrastructure — VPC, subnets, security groups, and EC2 instances — written from scratch using HCL.

```bash
cd "Week-1 introduction to Iac With Terraform"
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

**Key files to study:**

```
main.tf          # resource definitions
variables.tf     # input variables with types and defaults
outputs.tf       # values exported after apply
provider.tf      # AWS provider configuration
```

---

### Week 2 — State Management

**Concepts covered:**
- Why local state is dangerous in teams
- Remote state backends using S3 + DynamoDB locking
- `terraform state` commands: list, show, mv, rm
- State isolation per environment (dev / staging / prod)
- Bootstrapping backend infrastructure (the chicken-and-egg problem)
- Importing existing resources into state

**What you build:** S3 buckets and DynamoDB lock tables for each environment, with a bootstrap script to create them before Terraform manages anything else.

```bash
cd "Week-2 State Management"

# Bootstrap the remote backends first
bash scripts/bootstrap-backends.sh

# Then initialise with the remote backend
terraform init
terraform plan
terraform apply
```

**Backend configuration pattern used:**

```hcl
terraform {
  backend "s3" {
    bucket         = "myapp-tfstate-prod-<account-id>"
    key            = "prod/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "myapp-tflock-prod"
    encrypt        = true
  }
}
```

---

### Week 3 — Modules

**Concepts covered:**
- Module structure and best practices
- Input variables, outputs, and locals inside modules
- Calling local modules vs remote registry modules
- Module versioning and pinning
- The `for_each` and `count` meta-arguments
- Module composition patterns

**What you build:** A library of reusable modules — networking, compute, database, security, and monitoring — called from each environment root.

```
modules/
├── networking/    # VPC, subnets, route tables, NAT gateway
├── compute/       # EC2, Auto Scaling, Load Balancer
├── database/      # RDS with parameter groups and snapshots
├── security/      # IAM roles, security groups, KMS keys
└── monitoring/    # CloudWatch dashboards, alarms, SNS topics
```

Calling a module from an environment:

```hcl
module "networking" {
  source = "../../modules/networking"

  vpc_cidr        = var.vpc_cidr
  environment     = var.environment
  azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
}
```

---

### Week 4 — CI/CD and Drift Detection

**Concepts covered:**
- GitHub Actions workflow structure for Terraform
- Automated formatting, validation, and linting on PRs
- Security scanning with Gitleaks, TFLint, and Checkov
- Terraform plan output in GitHub Issues for manual approval
- The `trstringer/manual-approval` approval gate
- Automated drift detection on a cron schedule
- AI-assisted plan review using the Claude API
- Pre-commit hooks for local enforcement

**What you build:** A full GitHub Actions pipeline that enforces code quality, security, and a manual approval gate before any changes reach production.

```
.github/workflows/
├── terraform-ci.yml          # PR checks: fmt, validate, lint, security scan
├── terraform-cd.yml          # Plan → approval gate → apply
└── drift-detection.yml       # Nightly scheduled drift check
```

**Pipeline flow:**

```
PR opened
    │
    ├── Gitleaks (secret scan)
    ├── TFLint   (lint)
    └── Checkov  (security scan)
              │
              ▼ all pass
    Terraform Plan
              │
              ▼
    GitHub Issue created with plan output
    Manual approval required (comment "approved")
              │
              ▼
    Terraform Apply
              │
              ▼
    Nightly drift detection (cron)
```

---

## CI/CD Pipeline

### Secrets required

Add these in **GitHub → Settings → Secrets and variables → Actions**:

| Secret | Description |
|---|---|
| `AWS_ACCESS_KEY_ID` | AWS credentials for plan and apply |
| `AWS_SECRET_ACCESS_KEY` | AWS credentials for plan and apply |
| `ANTHROPIC_API_KEY` | For AI plan review (Week 4, optional) |

### Triggering the pipeline

```
Push to any branch    →  formatting + validation only
Open a PR to main     →  full security scan + plan + approval gate
Merge to main         →  apply to production
Every night at 06:00  →  drift detection
```

---

## Security Tooling

This repo uses a layered security approach — issues are caught as early as possible, ideally before they ever reach CI.

| Layer | Tool | What it catches |
|---|---|---|
| Pre-commit (local) | Gitleaks | Hardcoded secrets and credentials |
| Pre-commit (local) | TFLint | Lint errors, invalid resource arguments |
| Pre-commit (local) | Checkov | Security misconfigurations in HCL |
| Pre-commit (local) | `terraform fmt` | Formatting drift |
| Pre-commit (local) | `terraform validate` | Syntax errors and internal references |
| CI (GitHub Actions) | Gitleaks | Full git history secret scan |
| CI (GitHub Actions) | TFLint | Per-environment linting |
| CI (GitHub Actions) | Checkov | SARIF upload to GitHub Security tab |
| CI (GitHub Actions) | Trivy | IaC + container image CVEs |
| Scheduled | driftctl | Resources changed outside Terraform |
| Scheduled | Prowler | CIS benchmark compliance checks |

### Pre-commit configuration

The `.pre-commit-config.yaml` at the root enforces all local checks. Set it up once:

```bash
pre-commit install
pre-commit install --hook-type pre-push

# Test against all files manually
pre-commit run --all-files
```

---

## Folder Structure

```
Infrastructure-as-Code-Using-Terraform/
│
├── .github/
│   └── workflows/
│       ├── terraform-ci.yml
│       ├── terraform-cd.yml
│       └── drift-detection.yml
│
├── Week-1 introduction to Iac With Terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf
│
├── Week-2 State Management/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── backend.tf
│   └── scripts/
│       └── bootstrap-backends.sh
│
├── Week-3 Modules/
│   ├── modules/
│   │   ├── networking/
│   │   ├── compute/
│   │   ├── database/
│   │   ├── security/
│   │   └── monitoring/
│   └── environments/
│       ├── dev/
│       ├── staging/
│       └── prod/
│
├── Week-4 CI-CD Drift Detection/
│   ├── .github/workflows/
│   ├── .pre-commit-config.yaml
│   ├── .tflint.hcl
│   ├── .checkov.yaml
│   └── .gitleaks.toml
│
├── Books/                        # Reference material
├── .gitignore
├── .pre-commit-config.yaml
└── README.md
```

---

## Contributing

Contributions are welcome. Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes and ensure all pre-commit hooks pass: `pre-commit run --all-files`
4. Commit your changes: `git commit -m "feat: describe your change"`
5. Push to your fork: `git push origin feature/your-feature-name`
6. Open a pull request against `main`

**Commit message convention:**

```
feat:     new feature or resource
fix:      bug fix
docs:     documentation changes
refactor: code restructure without behaviour change
security: security improvement
ci:       CI/CD pipeline changes
```

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## Author

**kodcapsule** — [github.com/kodcapsule](https://github.com/kodcapsule)

---

> **Note:** This repository is actively developed as a learning resource. Each week folder is self-contained and can be followed independently, but working through them in order gives the best experience.


DB_HOST=localhost
DB_PORT=5432
DB_USER=jerney_user
DB_PASSWORD=jerney_pass_2026
DB_NAME=jerney_db
PORT=5000