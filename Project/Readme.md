# 🏗️ 3-Tier AWS Application Architecture with Terraform

> **Highly Available, Scalable, and Secure** — Infrastructure as Code on AWS

![Architecture Diagram](AWS-3-Tier%20Architecture.png)

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Project Deliverables](#project-deliverables)
- [Documentation & Screenshots](#documentation--screenshots)


---

## 📌 Project Overview
In this project, you will automate the provisioning of a **production-grade 3-tier AWS application architecture** using Terraform. The infrastructure provisioning should be automated via GitHub Actions (or Terraform Cloud), hardened with security tooling, and enforced through pre-commit hooks—ensuring a consistent, secure, and repeatable deployment pipeline.

### Key Benefits

| Benefit | Implementation |
|---|---|
| ✅ High Availability | Multi-AZ deployment across all tiers |
| ✅ Scalability | EC2 Auto Scaling for web and application tiers |
| ✅ Security | Isolated subnets, Security Groups, IAM least privilege |
| ✅ Data Durability | RDS Multi-AZ with synchronous replication |
| ✅ Performance | Optimised for production workloads |

---

## 🏛️ Architecture

The architecture follows a classic **3-Tier** pattern deployed across **two AWS Availability Zones (AZ-A and AZ-B)** within a single VPC.

```
Internet
    │
    ▼
Internet Gateway
    │
    ▼
┌─────────────────────────────────────────────────────┐
│  VPC  (10.0.0.0/16)                                  │
│                                                       │
│  ┌── AZ-A ──────────┐    ┌── AZ-B ──────────┐       │
│  │ Public Subnet A   │    │ Public Subnet B   │       │
│  │ 10.0.0.0/24       │◄──►│ 10.0.1.0/24       │       │
│  │  [Web Servers]    │    │  [Web Servers]    │       │
│  │  EC2 Auto Scaling │    │  EC2 Auto Scaling │       │
│  └───────────────────┘    └───────────────────┘       │
│           │  Application Load Balancer  │             │
│  ┌── AZ-A ──────────┐    ┌── AZ-B ──────────┐       │
│  │ Private Subnet A  │    │ Private Subnet B  │       │
│  │ 10.0.2.0/24       │◄──►│ 10.0.3.0/24       │       │
│  │  [App Servers]    │    │  [App Servers]    │       │
│  │  EC2 Auto Scaling │    │  EC2 Auto Scaling │       │
│  └───────────────────┘    └───────────────────┘       │
│           │  Application Load Balancer  │             │
│  ┌── AZ-A ──────────┐    ┌── AZ-B ──────────┐       │
│  │ DB Subnet A       │◄──►│ DB Subnet B       │       │
│  │ 10.0.4.0/24       │    │ 10.0.5.0/24       │       │
│  │  [RDS Primary]    │◄──►│  [RDS Standby]    │       │
│  │  Multi-AZ         │sync│  Multi-AZ         │       │
│  └───────────────────┘    └───────────────────┘       │
└─────────────────────────────────────────────────────┘
```

### Tier Breakdown

**Tier 1 — Web Tier (Public Subnets)**
- EC2 instances managed by Auto Scaling Group
- Application Load Balancer handles inbound HTTP/HTTPS
- Security Groups restrict traffic to ports 80/443

**Tier 2 — Application Tier (Private Subnets)**
- EC2 instances running business logic
- Only reachable from the Web Tier via internal ALB
- No direct internet access; egress via NAT Gateway

**Tier 3 — Database Tier (DB Subnets)**
- Amazon RDS (MySQL/PostgreSQL) in Multi-AZ mode
- Synchronous replication to standby in AZ-B
- Automatic failover with no manual intervention

---

## 🎯 Project Deliverables

### ✅ 1. Terraform Infrastructure
Provision the complete 3-tier architecture with Terraform modules:

- VPC, Subnets, Route Tables, Internet Gateway, NAT Gateway
- Application Load Balancers (Web and App tiers)
- EC2 Auto Scaling Groups with Launch Templates
- Amazon RDS (Multi-AZ) 
- Security Groups and NACLs
- IAM Roles and Instance Profiles

### ✅ 2. Automation — GitHub Actions / Terraform Cloud
Full CI/CD pipeline that:

- Runs `terraform fmt`, `validate`, and `plan` on every Pull Request
- Requires PR approval before `terraform apply`
- Posts plan output directly in PR comments
- Manages state remotely (S3 or Terraform Cloud)

### ✅ 3. Security Tooling Integration
Integrated security scanning tools:

- **trivy** 
- **checkov** 
- **terrascan** 
- **gitleaks** 
- **detect-secretes** 

And any other relevant security tool 

### ✅ 4. Pre-commit Hooks
Enforced local checks before every commit:

- `terraform fmt` — auto-format HCL
- `terraform validate` — syntax and schema validation
- `tfsec` — security lint on changed `.tf` files
- `detect-secrets` — prevent accidental credential commits
- `end-of-file-fixer` and `trailing-whitespace`

### ✅ 5. GitHub Repository Documentation
Documented GitHub repo including:

- Module READMEs
- Architecture diagram
- Workflow run screenshots
- Security scan output screenshots
- Terraform plan screenshots

---


## 📸 Documentation & Screenshots

Document your project  with screen prints with  following evidence for the project submission:

| Screenshot | Description |
|---|---|
| `01-github-repo-structure.png` | GitHub repo with all Terraform modules |
| `02-terraform-plan-pr.png` | Terraform plan output |
| `03-github-actions-pipeline.png` | Successful GitHub Actions workflow run |
| `04-tfsec-scan-results.png` | tfsec security scan results |
| `05-checkov-scan-results.png` | Checkov policy scan results |
| `06-pre-commit-hooks-run.png` | Pre-commit hooks passing locally |
| `07-aws-console-vpc.png` | VPC and subnets in AWS Console |
| `08-aws-console-ec2-asg.png` | EC2 Auto Scaling Groups running |
| `09-aws-console-rds-multiaz.png` | RDS Multi-AZ instance status |
| `10-aws-console-alb.png` | Application Load Balancers active |


## 📄 License

This project is submitted as part of a course work on Terraform. 
---

> Built with ❤️ using Terraform, AWS, GitHub Actions, and security best practices.
