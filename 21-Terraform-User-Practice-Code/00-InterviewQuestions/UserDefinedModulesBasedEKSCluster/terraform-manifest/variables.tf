variable "aws_profile" {
  description = "AWS profile to select appropriate credentials"
  type        = string
  default     = "default"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_vpc_cidr_block" {
  description = "CIDR block for vpc"
  type = string
  default = "10.0.0.0/8"
}

variable "aws_availability_zones" {
  description = "availability zones for subnets"
  type = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "aws_private_subnet_cidr_blocks" {
  description = "CIDR block for private subnets"
  type = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "aws_public_subnet_cidr_blocks" {
  description = "CIDR block for public subnets"
  type = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24"]
}

