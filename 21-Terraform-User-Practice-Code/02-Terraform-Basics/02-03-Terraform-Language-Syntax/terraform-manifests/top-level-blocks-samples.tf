# Terraform Block
terraform {
  required_version = "~> 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.50.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }
  /*
  backend "s3" {
    bucket         = "backend-terraform-tfstate-store"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "backend-terraform-tfstate-table"
  }
  */
}



# Provider Block
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

provider "aws" {
  profile = "default"
  region  = "us-west-1"
  alias   = "westUS"
}



# Resource Block
resource "aws_instance" "my-ec2-instance" {
  ami           = "ami-0965eacc05e445912"
  provider      = aws.westUS
  instance_type = var.instance-type
  key_name      = var.awsuser-key
}

resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"

  //tags = {
  //    name        = "my-vpc"
  //    environment = var.environment-name
  //}

  tags = merge(
    var.default-tags,
    {
      name = "my-vpc"
    }
  )
}



# Input Variable Block
variable "instance-type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "availability-zone" {
  description = "availability zone to deploy instance"
  type        = string
  default     = "us-east-1a"
}

variable "awsuser-key" {
  description = "awsuser key to login instances"
  type        = string
  default     = "awsuser-key"
}

variable "application-name" {
  description = "application name"
  type        = string
  default     = "sample-app"
}

variable "environment-name" {
  description = "environment name"
  type        = string
  default     = "dev"
}

variable "default-tags" {
  description = "default tagging for created resources"
  type        = map(string)
  default = {
    environment = "dev"
  }
}



# Output Value Block
output "aws_instance_public_ip" {
  description = "aws instance public ip"
  value       = aws_instance.my-ec2-instance.public_ip
}



# Local Value Block
locals {
  bucket-name = "${var.environment-name}-${var.application-name}"
}



# Data Source Block
data "aws_ami" "amzlinux" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}



# Module Block
module "ec2-instance" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"
  name                   = "my-ec2-instance"
  instance_count         = 3
  ami                    = data.aws_ami.amzlinux.id
  instance_type          = var.instance-type
  key_name               = var.awsuser-key
  monitoring             = true
  vpc_security_group_ids = ["sg-default", "sg-webapp"]
  subnet_id              = "my-vpc-${var.availability-zone}-private-subnet"
  user_data              = file("install-httpd.sh")
  tags = merge(
    var.default-tags,
    {
      name = var.application-name
    }
  )
}


##########################################################################

