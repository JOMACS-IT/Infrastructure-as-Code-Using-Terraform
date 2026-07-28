terraform {
  backend "s3" {
    bucket       = "junior-terraform-state-bucket"
    key          = "workspace-example/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true

  }
}