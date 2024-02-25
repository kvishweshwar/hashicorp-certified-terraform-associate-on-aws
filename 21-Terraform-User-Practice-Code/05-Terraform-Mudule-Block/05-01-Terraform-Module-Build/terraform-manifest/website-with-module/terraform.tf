terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.34.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.10.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.0"
    }
  }
  backend "s3" {
    bucket         = "backend-terraform-tfstate-store"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "backend-terraform-tfstate-table"
  }
}

provider "aws" {
  profile = "default"
  region  = var.aws_region
}