/*
output "bucket_region" {
  description = "region of bucket hosting static website"
  value       = aws_s3_bucket.my-bucket.region
}

output "bucket_id" {
  description = "id of bucket hosting static website"
  value       = aws_s3_bucket.my-bucket.id
}

output "bucket_name" {
  description = "name of bucket hosting static website"
  value       = aws_s3_bucket.my-bucket.bucket
}

output "bucket_arn" {
  description = "arn of bucket hosting static website"
  value       = aws_s3_bucket.my-bucket.arn
}
*/

output "bucket_domain_name" {
  description = "domain name of bucket hosting static website"
  value       = aws_s3_bucket.my-bucket.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "regional domain name of bucket hosting static website"
  value       = aws_s3_bucket.my-bucket.bucket_regional_domain_name
}

/*
output "bucket_static_website_domain" {
  description = "static website domain of bucket hosting static website"
  value       = aws_s3_bucket_website_configuration.my-bucket-website-config.website_domain
}

output "bucket_static_website_endpoint" {
  description = "static website endpoint of bucket hosting static website"
  value       = aws_s3_bucket_website_configuration.my-bucket-website-config.website_endpoint
}

output "bucket_static_website_url" {
  description = "static website url of bucket hosting static website"
  value = "http://${aws_s3_bucket.my-bucket.bucket}.s3-website.${aws_s3_bucket.my-bucket.region}.amazonaws.com"
}
*/




