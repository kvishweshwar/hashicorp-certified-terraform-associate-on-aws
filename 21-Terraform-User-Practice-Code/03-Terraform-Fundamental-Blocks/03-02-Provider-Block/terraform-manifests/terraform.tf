terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.3"
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
  region  = "us-east-1"
  default_tags {
    tags = {
      owner       = "devops"
    }
  }
}

