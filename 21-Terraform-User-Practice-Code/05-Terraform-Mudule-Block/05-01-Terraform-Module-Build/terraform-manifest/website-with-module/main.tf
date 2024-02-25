module "my-website" {
  source      = "./modules/s3-static-website"
  aws_region  = var.aws_region
  bucket_name = var.bucket_name
  index_file  = var.index_file
  bucket_tags = var.bucket_tags
}