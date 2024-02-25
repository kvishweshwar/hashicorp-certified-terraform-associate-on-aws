variable "aws_account_id" {
  description = "AWS account id to be used in resource creation."
  type        = number
  default     = "123456789012"
}

variable "aws_profile" {
  description = "AWS profile to use appropriate creds."
  type        = string
  default     = "default"
}

variable "aws_region" {
  description = "AWS region to deploy resources."
  type        = string
  default     = "us-east-1"
}

variable "aws_eks_cluster_name" {
  description = "AWS EKS cluster name."
  type        = string
  default     = "aws-eks-cluster"
}

variable "aws_vpc_cidr_block" {
  description = "AWS VPC CIDR block."
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_vpc_private_subnets" {
  description = "AWS VPC private subnets"
  type        = list(string)
  default = ["10.0.1.0/24","10.0.2.0/24"]
}

variable "aws_vpc_public_subnets" {
  description = "AWS VPC private subnets"
  type        = list(string)
  default = ["10.0.11.0/24","10.0.12.0/24"]
}

variable "aws_eks_cluster_version" {
  description = "AWS EKS cluster version."
  type        = string
  default     = "1.29"
}

variable "aws_eks_ec2_instance_type" {
  description = "AWS EKS EC2 instance type."
  type        = string
  default     = "m5.large"
}