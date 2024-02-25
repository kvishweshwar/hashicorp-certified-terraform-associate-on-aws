variable "my-ec2-instance-count" {
  description = "count of instances to be created"
  type        = number
  default     = 2
}

variable "my-vpc-web-application-sg-ingress-ports" {
  description = "ingress ports of my-vpc-web-application-sg"
  type        = list(string)
  default     = [80, 443]
}
