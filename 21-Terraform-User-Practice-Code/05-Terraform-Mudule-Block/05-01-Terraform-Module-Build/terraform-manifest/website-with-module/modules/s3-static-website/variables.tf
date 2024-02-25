variable "aws_region" {
  description = "aws region to deploy a bucket"
  type        = string
}

variable "bucket_name" {
  description = "bucket name to create a bucket"
  type        = string
}

variable "index_file" {
  description = "index file to upload in a bucket"
  type        = string
  nullable    = true
  default     = "./webapps/index.html"
}

variable "bucket_tags" {
  description = "bucket tags to attach to a bucket"
  type        = map(string)
  default     = {}
}
