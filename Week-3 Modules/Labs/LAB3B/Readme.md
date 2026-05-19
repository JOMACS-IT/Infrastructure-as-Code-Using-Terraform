# Terraform Refactoring LAB3B

## Safely Reorganise Infrastructure Without Destroying Resources

---

## Prerequisites

| Tool | Version |
|------|---------|
| Terraform | ≥ 1.5 |
| AWS CLI | configured with credentials |
| A terminal | bash  |



## Lab Overview

You will work through four independent but related scenarios, each targeting a different refactoring technique:

| # | Scenario | Technique |
|---|----------|-----------|
| 1 | Rename a resource in state | `terraform state mv` |
| 2 | Rename a resource declaratively | `moved` block |
| 3 | Adopt an existing resource into Terraform | `terraform import` |
| 4 | Drop a resource from state without deleting it | `removed` block |

Each scenario builds on a small, self-contained configuration so you can focus on the mechanics without noise.

---

## Scenario 1 — `terraform state mv`

### What it does

`terraform state mv` rewrites the state file directly. It tells Terraform "the thing at address A is now at address B" — no infrastructure is touched.

Use it for quick, one-off renames that you do not need to record in version control.

### Setup


### The rename




## Scenario 2 — `moved` Block

### What it does

The `moved` block is the declarative successor to `terraform state mv`. You record the rename in `.tf` source files, so the intent is committed to version control, reviewed in pull requests, and applied safely by everyone who runs `terraform apply`.


| Situation | Use |
|-----------|-----|
| Quick local experiment | `terraform state mv` |
| Team codebase with code review | `moved` block |
| Rename inside a module | `moved` block (supports `module.` paths) |
| Moving between backends | Neither — manual state surgery required |
| Automated CI pipeline | `moved` block (no manual step required) |

---

## Scenario 3 — `terraform import`

### What it does

`terraform import` (and its declarative sibling, the `import` block) brings an existing, unmanaged resource into Terraform state without recreating it. Use it when you provision something manually or via a script and want Terraform to take ownership.


### Method A — CLI import (Terraform < 1.5 compatible)





### Method B — `import` block (Terraform ≥ 1.5, recommended)


### Method C — generated config (Terraform ≥ 1.6)


## Scenario 4 — `removed` Block

### What it does

The `removed` block is the inverse of `import`. It tells Terraform to stop managing a resource — removing it from state — while leaving the real infrastructure intact. It is the declarative, reviewable alternative to `terraform state rm`.

### When you need it

- Handing a resource off to another team / Terraform workspace.
- Orphaning a resource intentionally (e.g., keeping a legacy database running outside IaC).
- Removing a resource from a module without deleting it in the real world.

### `removed` block vs `terraform state rm`

| | `removed` block | `terraform state rm` |
|---|---|---|
| Lives in VCS | ✓ | ✗ |
| Reviewable in PRs | ✓ | ✗ |
| Can destroy real resource | ✓ (`destroy = true`) | ✗ |
| Available since | Terraform 1.7 | All versions |

---

## Cleanup









## Further Reading

- [Terraform state subcommands](https://developer.hashicorp.com/terraform/cli/commands/state)
- [`moved` block reference](https://developer.hashicorp.com/terraform/language/moved)
- [`import` block reference](https://developer.hashicorp.com/terraform/language/import)
- [`removed` block reference](https://developer.hashicorp.com/terraform/language/resources/syntax#removing-resources)