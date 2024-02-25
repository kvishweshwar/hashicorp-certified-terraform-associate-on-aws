# Terraform Block

terraform {
  required_version = "~> 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }
  backend "s3" {
    bucket         = "backend-terraform-tfstate-store"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "backend-terraform-tfstate-table"
  }
}