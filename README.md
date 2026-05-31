# Infrastructure as Code Using Terraform 🚀

A hands-on, week-by-week learning series covering **Infrastructure as Code (IaC)** using **HashiCorp Terraform** — from fundamentals to advanced production patterns.

![Terraform](https://img.shields.io/badge/Terraform-1.x-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![HCL](https://img.shields.io/badge/HCL-100%25-blueviolet?style=for-the-badge)
![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

---

## 📋 Table of Contents

- [About This Repository](#about-this-repository)
- [Prerequisites](#prerequisites)
- [Course Structure](#course-structure)
  - [Week 1 – Introduction to IaC with Terraform](#week-1--introduction-to-iac-with-terraform)
  - [Week 2 – State Management](#week-2--state-management)
  - [Week 3 – Modules](#week-3--modules)
  - [Week 4 – CI/CD & Drift Detection](#week-4--cicd--drift-detection)
  - [Week 5 – Terraform Cloud & Spacelift](#week-5--terraform-cloud--spacelift)
- [Getting Started](#getting-started)
- [Folder Structure](#folder-structure)
- [Resources & Books](#resources--books)
- [Contributing](#contributing)
- [License](#license)

---

## About This Repository

This repository is a structured, progressive learning path for anyone who wants to master **Terraform** for real-world infrastructure automation. Each week builds on the previous one, introducing new concepts through practical examples and hands-on labs.

Whether you are a developer, DevOps engineer, or cloud architect, this series will equip you with the skills to write, manage, and scale infrastructure code with confidence.

---

## Prerequisites

Before you begin, make sure you have the following installed and configured:

- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) (v1.0+)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured with appropriate permissions
- A code editor (e.g., [VS Code](https://code.visualstudio.com/) with the HashiCorp Terraform extension)
- Basic understanding of cloud computing concepts (AWS recommended)
- Git installed and a GitHub account

---

## Course Structure

### Week 1 – Introduction to IaC with Terraform

📁 [`Week-1 introduction to Iac With Terraform`](./Week-1%20introduction%20to%20Iac%20With%20Terraform/)

**What You'll Learn:**
- What Infrastructure as Code (IaC) is and why it matters
- Overview of Terraform: architecture, providers, and the HCL language
- Terraform workflow: `init` → `plan` → `apply` → `destroy`
- Writing your first Terraform configuration to provision AWS resources
- Understanding `terraform.tfstate` and what it does

**Key Concepts:**
- Providers and Resources
- Variables and Outputs
- Data Sources
- The Terraform Registry

---

### Week 2 – State Management

📁 [`Week-2 State Management`](./Week-2%20State%20Management/)

**What You'll Learn:**
- Deep dive into Terraform state and why it is critical
- Local vs. remote state storage
- Configuring an S3 backend with DynamoDB state locking
- State commands: `terraform state list`, `mv`, `rm`, `pull`, `push`
- Handling state drift and resolving conflicts

**Key Concepts:**
- Remote Backends (S3 + DynamoDB)
- State Locking and Consistency
- Importing existing infrastructure with `terraform import`
- Sensitive data in state files

---

### Week 3 – Modules

📁 [`Week-3 Modules`](./Week-3%20Modules/)

**What You'll Learn:**
- Why modules are the building blocks of reusable Terraform code
- Creating your own custom modules
- Using modules from the Terraform Public Registry
- Passing inputs and returning outputs from modules
- Module versioning and best practices for module design

**Key Concepts:**
- Module structure (`main.tf`, `variables.tf`, `outputs.tf`)
- Root module vs. child modules
- Module composition and nesting
- The `source` and `version` arguments

---

### Week 4 – CI/CD & Drift Detection

📁 [`Week-4  CI-CD Drift Detection`](./Week-4%20%20CI-CD%20Drift%20Detection/)

**What You'll Learn:**
- Integrating Terraform into CI/CD pipelines (GitHub Actions)
- Automating `terraform plan` and `terraform apply` safely
- What infrastructure drift is and why it happens
- Implementing automated drift detection using scheduled workflows
- Handling drift alerts and remediation strategies

**Key Concepts:**
- GitHub Actions workflows for Terraform
- `terraform plan -detailed-exitcode` for drift detection
- Storing plan artifacts and reviewing changes in Pull Requests
- Environment-based deployments (dev, staging, prod)
- OIDC-based authentication with AWS (no long-lived credentials)

---

### Week 5 – Terraform Cloud & Spacelift

📁 [`Week-5 Terraform Cloud & Spacelift`](./Week-5%20Terraform%20Cloud%20%26%20Spacelift/)

**What You'll Learn:**
- What Terraform Cloud (HCP Terraform) is and how it differs from the open-source CLI
- Setting up a Terraform Cloud organisation, workspaces, and VCS-driven workflows
- Remote state management and remote plan/apply execution in Terraform Cloud
- Introduction to **Spacelift** as a powerful alternative IaC management platform
- Connecting your GitHub repository to Spacelift stacks for GitOps-driven deployments
- Policy as Code with **Sentinel** (Terraform Cloud) and Spacelift policies
- Comparing Terraform Cloud vs Spacelift: when to use each

**Key Concepts:**

| Feature | Terraform Cloud (HCP Terraform) | Spacelift |
|---|---|---|
| Remote State | ✅ Native backend | ✅ Managed state |
| VCS Integration | GitHub, GitLab, Bitbucket | GitHub, GitLab, Bitbucket, Azure DevOps |
| Policy as Code | Sentinel | OPA-based policies |
| Drift Detection | ✅ Health assessments | ✅ Built-in drift detection |
| Multi-IaC Support | Terraform / OpenTofu | Terraform, Pulumi, CloudFormation, Ansible |
| Self-hosted Agents | ✅ Terraform Cloud Agents | ✅ Spacelift private workers |

**Hands-On Labs:**

1. **Lab 5.1 – Terraform Cloud Setup:** Create a free Terraform Cloud account, configure an organisation, link a VCS-connected workspace to this repository, and trigger a remote `plan` and `apply`.

2. **Lab 5.2 – Remote State in Terraform Cloud:** Migrate local state to a Terraform Cloud workspace backend and observe cross-workspace state sharing using `terraform_remote_state`.

3. **Lab 5.3 – Sentinel Policy Enforcement:** Write a Sentinel policy that prevents any EC2 instance from being provisioned with an instance type outside an approved list. Attach it to your Terraform Cloud workspace.

4. **Lab 5.4 – Spacelift Stack:** Create a Spacelift account, connect this repository, and configure a Stack that mirrors your Terraform Cloud workspace — including drift detection and approval-gated applies.

**Terraform Cloud Backend Configuration:**
```hcl
# backend.tf
terraform {
  cloud {
    organization = "your-org-name"

    workspaces {
      name = "iac-terraform-week5"
    }
  }
}
```

**Sample Sentinel Policy:**
```python
# policies/allowed-instance-types.sentinel
import "tfplan/v2" as tfplan

allowed_types = ["t3.micro", "t3.small", "t3.medium"]

ec2_instances = filter tfplan.resource_changes as _, rc {
  rc.type is "aws_instance" and
  rc.mode is "managed" and
  (rc.change.actions contains "create" or rc.change.actions contains "update")
}

violations = filter ec2_instances as _, instance {
  instance.change.after.instance_type not in allowed_types
}

main = rule {
  length(violations) is 0
}
```

**Connecting Spacelift to GitHub:**
```bash
# 1. Create a Spacelift account at https://spacelift.io
# 2. Install the Spacelift GitHub App on your repository
# 3. Create a new Stack in the Spacelift UI:
#    - VCS: GitHub → select this repository
#    - Project root: "Week-5 Terraform Cloud & Spacelift"
#    - Runner image: Default (includes Terraform)
#    - Set AWS credentials as Spacelift environment variables or use dynamic credentials
# 4. Trigger a tracked run — Spacelift will plan on every push and apply on merge to main
```

**Key Takeaways:**
- Terraform Cloud and Spacelift both solve the problem of running Terraform safely at scale — with remote execution, state management, and access control
- Sentinel (Terraform Cloud) and OPA policies (Spacelift) shift compliance checks left, preventing non-compliant infrastructure from ever being applied
- Spacelift's multi-IaC support and flexible policy engine make it a strong choice for organisations using more than just Terraform
- Both platforms support private/self-hosted agents for use inside private networks

---

## Getting Started

```bash
# 1. Clone the repository
git clone https://github.com/kodcapsule/Infrastructure-as-Code-Using-Terraform.git
cd Infrastructure-as-Code-Using-Terraform

# 2. Navigate to any week's folder
cd "Week-1 introduction to Iac With Terraform"

# 3. Initialize Terraform
terraform init

# 4. Preview the changes
terraform plan

# 5. Apply the configuration
terraform apply

# 6. Clean up resources when done
terraform destroy
```

> ⚠️ **Important:** Always review `terraform plan` output carefully before running `terraform apply`. Destroying resources may result in data loss.

---

## Folder Structure

```
Infrastructure-as-Code-Using-Terraform/
│                 
│
├── Books/                          
│
├── Week-1 introduction to Iac With Terraform/
├── Week-2 State Management/
├── Week-3 Modules/
├── Week-4  CI-CD Drift Detection/
├── Week-5 Terraform Cloud & Spacelift/
│
├── .gitignore
└── README.md
```

---

## Resources & Books

The `Books/` directory contains curated reading materials to complement the weekly labs. Additional recommended resources:

- 📖 [Terraform: Up & Running (3rd Edition)](https://www.terraformupandrunning.com/) – Yevgeniy Brikman
- 📖 [HashiCorp Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- 📖 [Terraform Best Practices](https://www.terraform-best-practices.com/)
- 🎓 [HashiCorp Learn](https://developer.hashicorp.com/terraform/tutorials)
- ☁️ [Terraform Cloud (HCP Terraform) Documentation](https://developer.hashicorp.com/terraform/cloud-docs)
- 🚀 [Spacelift Documentation](https://docs.spacelift.io/)
- 📜 [Sentinel Policy Language](https://developer.hashicorp.com/sentinel/docs)

---

## Contributing

Contributions are welcome! If you find a bug, want to improve an example, or have ideas for additional labs:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/your-feature-name`)
3. Make your changes and commit (`git commit -m 'Add your message'`)
4. Push to your branch (`git push origin feature/your-feature-name`)
5. Open a Pull Request

Please follow the existing folder and naming conventions when adding new content.

---

## License

This project is licensed under the **MIT License** — see the [LICENSE](./LICENSE) file for details.

---

<div align="center">

**⭐ If you find this repository helpful, please give it a star! ⭐**

Made with ❤️ by [kodcapsule](https://github.com/kodcapsule)

</div>
