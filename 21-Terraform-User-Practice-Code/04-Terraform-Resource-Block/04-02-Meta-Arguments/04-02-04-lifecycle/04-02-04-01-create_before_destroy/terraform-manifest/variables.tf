variable "my-ec2-instance-count" {
  description = "count of instances to be created"
  type        = number
  default     = 2
}



//This way is used with dynamic egress/ingress object.

variable "my-vpc-default-sg" {
  description = "egress/ingress ports of my-vpc-default-sg"
  type = object({
    egress-ports  = list(string)
    ingress-ports = list(string)
  })
  default = {
    egress-ports  = [0]
    ingress-ports = [22, 3389]
  }
}



// This is another way of creating egress/ingress object.

variable "my-vpc-web-application-sg-egress-rule" {
  description = "list of egress rule objects of my-vpc-web-application-sg"
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
  description = "list of ingress rule objects of my-vpc-web-application-sg"
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

