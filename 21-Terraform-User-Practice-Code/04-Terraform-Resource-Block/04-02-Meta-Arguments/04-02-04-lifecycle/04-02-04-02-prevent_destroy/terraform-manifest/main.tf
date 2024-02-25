resource "aws_vpc" "my-vpc" {
  cidr_block = var.my-vpc-cidr-block
  tags = {
    name = "my-vpc"
  }
}

resource "aws_subnet" "my-vpc-public-subnet" {
  vpc_id                  = aws_vpc.my-vpc.id
  count                   = length(var.my-vpc-public-subnet)
  cidr_block              = var.my-vpc-public-subnet[count.index].cidr_block
  availability_zone       = var.my-vpc-public-subnet[count.index].availability_zone
  map_public_ip_on_launch = true
  tags = {
    name = "my-vpc-${var.my-vpc-public-subnet[count.index].availability_zone}-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "my-vpc-private-subnet" {
  vpc_id            = aws_vpc.my-vpc.id
  count             = length(var.my-vpc-private-subnet)
  cidr_block        = var.my-vpc-private-subnet[count.index].cidr_block
  availability_zone = var.my-vpc-private-subnet[count.index].availability_zone
  tags = {
    name = "my-vpc-${var.my-vpc-private-subnet[count.index].availability_zone}-private-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "my-vpc-igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    name = "my-vpc-igw"
  }
}

resource "aws_nat_gateway" "my-vpc-ngw" {
  count      = length(var.my-vpc-public-subnet)
  subnet_id  = element(aws_subnet.my-vpc-public-subnet[*].id, count.index)
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
  count  = length(var.my-vpc-private-subnet)
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.my-vpc-ngw[*].id, count.index)
  }
  tags = {
    name = "my-vpc-private-route-table-${count.index + 1}"
  }
}

resource "aws_route_table_association" "my-vpc-public-route-table-subnet-association" {
  count          = length(var.my-vpc-public-subnet)
  subnet_id      = element(aws_subnet.my-vpc-public-subnet[*].id, count.index)
  route_table_id = aws_route_table.my-vpc-public-route-table.id
}

resource "aws_route_table_association" "my-vpc-private-route-table-subnet-association" {
  count          = length(var.my-vpc-private-subnet)
  subnet_id      = element(aws_subnet.my-vpc-private-subnet[*].id, count.index)
  route_table_id = element(aws_route_table.my-vpc-private-route-table[*].id, count.index)
}

resource "aws_route_table_association" "my-vpc-public-route-table-gateway-association" {
  gateway_id     = aws_internet_gateway.my-vpc-igw.id
  route_table_id = aws_route_table.my-vpc-public-route-table.id
}

// NAT Gateway association to a private route table is not possible
// Because aws_route_table_association don't have nat_gateway_id argument
/*
resource "aws_route_table_association" "my-vpc-private-route-table-nat-gateway-association" {
  count = length(var.my-vpc-private-subnet)
  nat_gateway_id = element(aws_nat_gateway.my-vpc-ngw[*].id, count.index)
  route_table_id = element(aws_route_table.my-vpc-private-route-table[*].id, count.index)
}
*/



resource "aws_security_group" "my-vpc-default-sg" {
  description = "allow inbound traffic for specific ports and all outbound traffic"
  name        = "my-vpc-default-sg"
  vpc_id      = aws_vpc.my-vpc.id
  tags = {
    name = "my-vpc-default-sg"
  }
  dynamic "egress" {
    for_each = var.my-vpc-default-sg.egress_ports
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  dynamic "ingress" {
    for_each = var.my-vpc-default-sg.ingress_ports
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

  count       = length(var.my-vpc-web-application-sg-egress-rule)
  from_port   = var.my-vpc-web-application-sg-egress-rule[count.index].from_port
  to_port     = var.my-vpc-web-application-sg-egress-rule[count.index].to_port
  protocol    = var.my-vpc-web-application-sg-egress-rule[count.index].protocol
  cidr_blocks = [var.my-vpc-web-application-sg-egress-rule[count.index].cidr_blocks]
}

resource "aws_security_group_rule" "my-vpc-web-application-sg-ingress-rule" {
  type              = "ingress"
  description       = "ingress rule for my-vpc-web-application-sg"
  security_group_id = aws_security_group.my-vpc-web-application-sg.id

  count       = length(var.my-vpc-web-application-sg-ingress-rule)
  from_port   = var.my-vpc-web-application-sg-ingress-rule[count.index].from_port
  to_port     = var.my-vpc-web-application-sg-ingress-rule[count.index].to_port
  protocol    = var.my-vpc-web-application-sg-ingress-rule[count.index].protocol
  cidr_blocks = [var.my-vpc-web-application-sg-ingress-rule[count.index].cidr_blocks]
}

resource "random_shuffle" "my-vpc-availability-zone" {
  input        = var.my-vpc-availability-zone.eastUS
  result_count = 1
}
// random_shuffle resource takes input as list(string) and give output as list(string)
// hence, to select only string value, we have to provide index in result like .result[0]


resource "aws_instance" "my-ec2-instance" {
  count                  = var.my-ec2-instance-count
  ami                    = var.my-ec2-instance-ami
  instance_type          = "t2.micro"
  key_name               = "awsuser-key"
  user_data              = file("install-httpd.sh")
  availability_zone      = random_shuffle.my-vpc-availability-zone.result[0]
  subnet_id              = aws_subnet.my-vpc-public-subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.my-vpc-default-sg.id, aws_security_group.my-vpc-web-application-sg.id]
  tags = {
    name = "my-ec2-instance-${count.index + 1}"
  }
  lifecycle {
    prevent_destroy = true
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



