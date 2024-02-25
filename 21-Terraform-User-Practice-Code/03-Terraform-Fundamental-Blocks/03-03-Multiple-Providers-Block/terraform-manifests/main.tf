# Resource block

resource "aws_instance" "my-ec2-instance" {
  provider      = aws.westUS
  ami           = "ami-0965eacc05e445912"
  instance_type = "t2.micro"
  key_name      = "awsuser-key"
  count         = 2
  tags = {
    name = "my-ec2-instance-${count.index}"
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
