output "my-ec2-instance-public-ip" {
  description = "public ip of launched ec2 instances"
  value       = aws_instance.my-ec2-instance[*].public_ip
}

