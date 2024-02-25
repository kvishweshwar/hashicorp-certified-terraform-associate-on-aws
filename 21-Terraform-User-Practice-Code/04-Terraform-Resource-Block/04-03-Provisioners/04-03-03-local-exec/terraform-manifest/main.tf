resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc-cidr-block
  tags = {
    name = "my-vpc"
  }
}

resource "aws_subnet" "my-vpc-public-subnet" {
  vpc_id                  = aws_vpc.my-vpc.id
  count                   = length(data.aws_availability_zones.aws-availability-zones.names)
  cidr_block              = var.vpc-public-subnet-cidr-block[count.index]
  availability_zone       = data.aws_availability_zones.aws-availability-zones.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    name = "my-vpc-${data.aws_availability_zones.aws-availability-zones.names[count.index]}-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "my-vpc-private-subnet" {
  vpc_id            = aws_vpc.my-vpc.id
  count             = length(data.aws_availability_zones.aws-availability-zones.names)
  cidr_block        = var.vpc-private-subnet-cidr-block[count.index]
  availability_zone = data.aws_availability_zones.aws-availability-zones.names[count.index]
  tags = {
    name = "my-vpc-${data.aws_availability_zones.aws-availability-zones.names[count.index]}-private-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "my-vpc-igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    name = "my-vpc-igw"
  }
}

resource "aws_nat_gateway" "my-vpc-ngw" {
  count      = length(data.aws_availability_zones.aws-availability-zones.names)
  subnet_id  = element(aws_subnet.my-vpc-private-subnet[*].id, count.index)
  depends_on = [aws_internet_gateway.my-vpc-igw]
  tags = {
    name = "my-vpc-ngw-${count.index + 1}"
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

resource "aws_route_table" "my-vpc-private-route-table" {
  vpc_id = aws_vpc.my-vpc.id
  count  = length(data.aws_availability_zones.aws-availability-zones.names)
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.my-vpc-ngw[*].id, count.index)
  }
  tags = {
    name = "my-vpc-private-route-table-${count.index + 1}"
  }
}

resource "aws_route_table_association" "my-vpc-public-route-table-gateway-association" {
  gateway_id     = aws_internet_gateway.my-vpc-igw.id
  route_table_id = aws_route_table.my-vpc-public-route-table.id
}

resource "aws_route_table_association" "my-vpc-public-route-table-subnet-association" {
  count          = length(data.aws_availability_zones.aws-availability-zones.names)
  subnet_id      = element(aws_subnet.my-vpc-public-subnet[*].id, count.index)
  route_table_id = aws_route_table.my-vpc-public-route-table.id
}

resource "aws_route_table_association" "my-vpc-private-route-table-subnet-association" {
  count          = length(data.aws_availability_zones.aws-availability-zones.names)
  subnet_id      = element(aws_subnet.my-vpc-private-subnet[*].id, count.index)
  route_table_id = element(aws_route_table.my-vpc-private-route-table[*].id, count.index)
}

resource "aws_security_group" "my-vpc-default-sg" {
  description = "allow inbound traffic for specific ports and all outbound traffic"
  name        = "my-vpc-default-sg"
  vpc_id      = aws_vpc.my-vpc.id
  tags = {
    name = "my-vpc-default-sg"
  }
  dynamic "egress" {
    for_each = toset(var.vpc-default-sg.egress_ports)
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  dynamic "ingress" {
    for_each = toset(var.vpc-default-sg.ingress_ports)
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

resource "aws_security_group" "my-vpc-web-application-sg" {
  description = "allow inbound traffic for specific ports and all outbound traffic"
  name        = "my-vpc-web-application-sg"
  vpc_id      = aws_vpc.my-vpc.id
  tags = {
    name = "my-vpc-web-application-sg"
  }
}

resource "aws_security_group_rule" "my-vpc-web-application-sg-egress-rule" {
  type              = "egress"
  description       = "egress rule for my-vpc-web-application-sg"
  security_group_id = aws_security_group.my-vpc-web-application-sg.id

  count       = length(var.vpc-web-application-sg-egress-rule)
  from_port   = var.vpc-web-application-sg-egress-rule[count.index].from_port
  to_port     = var.vpc-web-application-sg-egress-rule[count.index].to_port
  protocol    = var.vpc-web-application-sg-egress-rule[count.index].protocol
  cidr_blocks = [var.vpc-web-application-sg-egress-rule[count.index].cidr_blocks]
}

resource "aws_security_group_rule" "my-vpc-web-application-sg-ingress-rule" {
  type              = "ingress"
  description       = "ingress rule for my-vpc-web-application-sg"
  security_group_id = aws_security_group.my-vpc-web-application-sg.id

  count       = length(var.vpc-web-application-sg-ingress-rule)
  from_port   = var.vpc-web-application-sg-ingress-rule[count.index].from_port
  to_port     = var.vpc-web-application-sg-ingress-rule[count.index].to_port
  protocol    = var.vpc-web-application-sg-ingress-rule[count.index].protocol
  cidr_blocks = [var.vpc-web-application-sg-ingress-rule[count.index].cidr_blocks]
}

resource "random_shuffle" "my-ec2-instance-availability-zone" {
  input        = data.aws_availability_zones.aws-availability-zones.names
  result_count = 1
}

resource "aws_instance" "my-ec2-instance" {
  count                  = var.ec2-instance-count
  ami                    = data.aws_ami.aws-ami.id
  instance_type          = "t2.micro"
  key_name               = "awsuser-key"
  user_data              = file("install-httpd.sh")
  // availability_zone      = random_shuffle.my-ec2-instance-availability-zone.result[0]
  // While using availability_zone with random_shuffle; we can not guarantee about assigning correct/matching subnet_id. Hence, disabled.
  subnet_id              = aws_subnet.my-vpc-public-subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.my-vpc-default-sg.id, aws_security_group.my-vpc-web-application-sg.id]
  tags = {
    name = "my-ec2-instance-${count.index + 1}"
  }

  // local-exec provisioner running on instance creation time (Hence, known as Creation-Time provisioner)
  provisioner "local-exec" {
    working_dir = "instanceinfo/"
    //command     = "echo ${element(aws_instance.my-ec2-instance[*].private_ip, count.index)} >> ./instanceinfo/instanceinfo.txt"
    command = "echo ${self.private_ip} is created on $(date) >> ./instanceinfo/instanceinfo.txt"
  }

  // local-exec provisioner running on instance deletion time (Hence, known as Destroy-Time provisioner)
  provisioner "local-exec" {
    when        = destroy
    working_dir = "instanceinfo/"
    //command = "echo ${element(aws_instance.my-ec2-instance[*].private_ip, count.index)} is deleted on $(date) >> ./instanceinfo/instanceinfo.txt"
    command = "echo ${self.private_ip} is deleted on $(date) >> ./instanceinfo/instanceinfo.txt"
  }

}

resource "aws_eip" "my-vpc-eip" {
  domain     = "vpc"
  count      = var.ec2-instance-count
  instance   = element(aws_instance.my-ec2-instance[*].id, count.index)
  depends_on = [aws_internet_gateway.my-vpc-igw]
  tags = {
    name = "my-vpc-eip-${count.index + 1}"
  }
}





