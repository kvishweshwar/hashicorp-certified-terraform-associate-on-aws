data "aws_ami" "aws-ami" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_availability_zones" "aws-availability-zones" {
  // state = "available" ### this will list all zones (availability zone as well as local zone)
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}



