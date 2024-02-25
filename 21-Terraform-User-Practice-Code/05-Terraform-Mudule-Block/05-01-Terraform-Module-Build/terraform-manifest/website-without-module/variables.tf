variable "aws_region" {
  description = "aws region to deploy a bucket"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "bucket name to create a bucket"
  type        = string
  default     = "static-website-store"
}

variable "bucket_tags" {
  description = "bucket tags to attach to a bucket"
  type        = map(string)
  default     = {}
}


