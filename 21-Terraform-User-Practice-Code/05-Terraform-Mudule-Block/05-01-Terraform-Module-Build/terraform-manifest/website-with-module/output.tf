/*
output "bucket_region" {
  description = "region of bucket hosting static website"
  value       = module.my-website.region
}

output "bucket_id" {
  description = "id of bucket hosting static website"
  value       = module.my-website.id
}

output "bucket_name" {
  description = "name of bucket hosting static website"
  value       = module.my-website.bucket
}

output "bucket_arn" {
  description = "arn of bucket hosting static website"
  value       = module.my-website.arn
}
*/

output "bucket_domain_name" {
  description = "domain name of bucket hosting static website"
  value       = module.my-website.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "regional domain name of bucket hosting static website"
  value       = module.my-website.bucket_regional_domain_name
}

/*
output "bucket_static_website_domain" {
  description = "static website domain of bucket hosting static website"
  value       = module.my-website.website_domain
}

output "bucket_static_website_endpoint" {
  description = "static website endpoint of bucket hosting static website"
  value       = module.my-website.website_endpoint
}

output "bucket_static_website_url" {
  description = "static website url of bucket hosting static website"
  value = "http://${module.my-website.bucket}.s3-website.${module.my-website.region}.amazonaws.com"
}
*/




