# Terraform resource block

resource "aws_instance" "my-ec2-instance" {
  ami               = "ami-046eeba8a7f7bbefd"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "awsuser-key"
  user_data         = file("install-httpd.sh")
  count             = 2
  tags = {
    name = "my-ec2-instance-${count.index}"
    environment = "dev"
  }
}


output "aws_instance_id" {
  description = "aws instance id"
  value       = aws_instance.my-ec2-instance[*].id
}

output "aws_instance_name" {
  description = "aws instance name"
  value       = aws_instance.my-ec2-instance[*].tags["name"]
}

output "aws_instance_public_ip" {
  description = "aws instance public ip"
  value       = aws_instance.my-ec2-instance[*].public_ip
}
