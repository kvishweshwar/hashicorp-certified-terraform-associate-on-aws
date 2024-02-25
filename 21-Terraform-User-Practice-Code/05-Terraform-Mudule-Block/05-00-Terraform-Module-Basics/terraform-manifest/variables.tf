variable "aws-region" {
  description = "aws region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc-cidr-block" {
  description = "cidr block for vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ec2-instance-count" {
  description = "count of ec2 instances to be launched"
  type        = number
  default     = 9
}

variable "vpc-public-subnet-cidr-block" {
  description = "number of public subnets to be created"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
}

variable "vpc-private-subnet-cidr-block" {
  description = "number of public subnets to be created"
  type        = list(string)
  default     = ["10.0.50.0/24", "10.0.51.0/24", "10.0.52.0/24", "10.0.53.0/24", "10.0.54.0/24", "10.0.55.0/24"]
}

variable "vpc-default-sg" {
  description = "egress/ingress ports of my-vpc-default-sg"
  type = object({
    egress_ports  = list(string)
    ingress_ports = list(string)
  })
  default = {
    egress_ports  = [0]
    ingress_ports = [22, 3389]
  }
}

variable "vpc-web-application-sg-egress-rule" {
  description = "engress rule for my-vpc-web-application-sg"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = string
  }))
  default = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "0.0.0.0/0"
  }]
}

variable "vpc-web-application-sg-ingress-rule" {
  description = "ingress rule for my-vpc-web-application-sg"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = string
  }))
  default = [{
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
  }]
}







