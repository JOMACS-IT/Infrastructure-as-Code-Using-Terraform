terraform {
  backend "s3" {
    bucket         = "file-layouts-terraform-bucket"
    key            = "file-layouts-environment/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile = true
  }
}