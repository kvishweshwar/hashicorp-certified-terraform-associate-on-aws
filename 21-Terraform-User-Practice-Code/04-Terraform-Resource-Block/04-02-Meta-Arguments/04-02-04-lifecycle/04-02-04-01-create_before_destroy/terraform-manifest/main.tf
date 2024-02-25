resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name = "my-vpc"
  }
}

resource "aws_subnet" "my-vpc-us-east-1a-public-subnet-1" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    name = "my-vpc-us-east-1a-public-subnet-1"
  }
}

resource "aws_internet_gateway" "my-vpc-igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    name = "my-vpc-igw"
  }
}

resource "aws_route_table" "my-vpc-public-route-table" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-vpc-igw.id
  }
  tags = {
    name = "my-vpc-public-route-table"
  }
}

resource "aws_route_table_association" "my-vpc-public-route-table-subnet-association" {
  subnet_id      = aws_subnet.my-vpc-us-east-1a-public-subnet-1.id
  route_table_id = aws_route_table.my-vpc-public-route-table.id
}

resource "aws_route_table_association" "my-vpc-public-route-table-gateway-association" {
  gateway_id     = aws_internet_gateway.my-vpc-igw.id
  route_table_id = aws_route_table.my-vpc-public-route-table.id
}

resource "aws_security_group" "my-vpc-default-sg" {
  description = "allow inbound traffic for specific ports and all outbound traffic"
  name        = "my-vpc-default-sg"
  vpc_id      = aws_vpc.my-vpc.id
  tags = {
    name = "my-vpc-default-sg"
  }
  dynamic "egress" {
    // description not allowed in dynamic egress
    // description = "allow all outbound traffic"
    for_each = var.my-vpc-default-sg.egress-ports
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  dynamic "ingress" {
    // description not allowed in dynamic ingress
    // description = "allow inbound traffic for specific ports"
    for_each = var.my-vpc-default-sg.ingress-ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

resource "aws_security_group" "my-vpc-web-application-sg" {
  description = "allow inbound traffic to specific ports and all outbound traffic"
  name        = "my-vpc-web-application-sg"
  vpc_id      = aws_vpc.my-vpc.id
  tags = {
    name = "my-vpc-web-application-sg"
  }
}

resource "aws_security_group_rule" "my-vpc-web-application-sg-egress-rule" {
  type              = "egress"
  description       = "egress rule of my-vpc-web-application-sg"
  security_group_id = aws_security_group.my-vpc-web-application-sg.id

  count = length(var.my-vpc-web-application-sg-egress-rule)

  from_port   = var.my-vpc-web-application-sg-egress-rule[count.index].from_port
  to_port     = var.my-vpc-web-application-sg-egress-rule[count.index].to_port
  protocol    = var.my-vpc-web-application-sg-egress-rule[count.index].protocol
  cidr_blocks = [var.my-vpc-web-application-sg-egress-rule[count.index].cidr_blocks]
}

resource "aws_security_group_rule" "my-vpc-web-application-sg-ingress-rule" {
  type              = "ingress"
  description       = "ingress rule of my-vpc-web-application-sg"
  security_group_id = aws_security_group.my-vpc-web-application-sg.id

  count = length(var.my-vpc-web-application-sg-ingress-rule)

  from_port   = var.my-vpc-web-application-sg-ingress-rule[count.index].from_port
  to_port     = var.my-vpc-web-application-sg-ingress-rule[count.index].to_port
  protocol    = var.my-vpc-web-application-sg-ingress-rule[count.index].protocol
  cidr_blocks = [var.my-vpc-web-application-sg-ingress-rule[count.index].cidr_blocks]
}

resource "aws_instance" "my-ec2-instance" {
  count                  = var.my-ec2-instance-count
  ami                    = "ami-046eeba8a7f7bbefd"
  instance_type          = "t2.micro"
  key_name               = "awsuser-key"
  availability_zone      = "us-east-1a"
  user_data              = file("install-httpd.sh")
  subnet_id              = aws_subnet.my-vpc-us-east-1a-public-subnet-1.id
  vpc_security_group_ids = [aws_security_group.my-vpc-default-sg.id, aws_security_group.my-vpc-web-application-sg.id]
  tags = {
    name = "my-ec2-instance-${count.index + 1}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "my-vpc-eip" {
  domain     = "vpc"
  count      = var.my-ec2-instance-count
  instance   = element(aws_instance.my-ec2-instance[*].id, count.index)
  depends_on = [aws_internet_gateway.my-vpc-igw]
  tags = {
    name = "my-vpc-eip-${count.index + 1}"
  }
}





