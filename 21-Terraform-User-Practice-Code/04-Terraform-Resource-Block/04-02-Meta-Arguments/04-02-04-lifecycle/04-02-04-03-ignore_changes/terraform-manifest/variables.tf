variable "my-vpc-cidr-block" {
  description = "vpc cidr block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "my-ec2-instance-count" {
  description = "count of ec2 instances to be created"
  type        = number
  default     = 2
}

variable "my-ec2-instance-ami" {
  description = "ami id to launch ec2 instance"
  type        = string
  default     = "ami-046eeba8a7f7bbefd"
}

variable "my-vpc-public-subnet" {
  description = "number of public subnets to be created"
  type = list(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = [{
    cidr_block        = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    },
    {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-east-1b"
    },
    {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "us-east-1c"
  }]
}

variable "my-vpc-private-subnet" {
  description = "number of private subnets to be created"
  type = list(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = [{
    cidr_block        = "10.0.10.0/24"
    availability_zone = "us-east-1a"
    },
    {
      cidr_block        = "10.0.11.0/24"
      availability_zone = "us-east-1b"
    },
    {
      cidr_block        = "10.0.12.0/24"
      availability_zone = "us-east-1c"
  }]
}

variable "my-vpc-default-sg" {
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

variable "my-vpc-web-application-sg-egress-rule" {
  description = "engress rule of my-vpc-web-application-sg"
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

variable "my-vpc-web-application-sg-ingress-rule" {
  description = "ingress rule of my-vpc-web-application-sg"
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








