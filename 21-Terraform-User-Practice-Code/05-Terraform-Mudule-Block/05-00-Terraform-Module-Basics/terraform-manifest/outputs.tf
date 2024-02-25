/*
output "my-ec2-instance-public-ip" {
  description = "public ip of launched ec2 instances"
  value       = aws_instance.my-ec2-instance[*].public_ip
}
*/

output "ec2_cluster-public_ip" {
  description = "public ip of launched ec2 instance"
  value       = module.ec2_cluster[*].public_ip
}
