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
}

resource "aws_route" "my-vpc-public-route-table-outbound-route" {
  destination_cidr_block     = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.my-vpc-igw.id
  route_table_id = aws_route_table.my-vpc-public-route-table.id
}

resource "aws_route_table_association" "my-vpc-public-route-table-gateway-association" {
  gateway_id     = aws_internet_gateway.my-vpc-igw.id
  route_table_id = aws_route_table.my-vpc-public-route-table.id
}

resource "aws_route_table_association" "my-vpc-public-route-table-subnet-association" {
  subnet_id      = aws_subnet.my-vpc-us-east-1a-public-subnet-1.id
  route_table_id = aws_route_table.my-vpc-public-route-table.id
}

resource "aws_security_group" "my-vpc-default-sg" {
  description = "allow inbound traffic for default ports and all outbound traffic"
  name        = "my-vpc-default-sg"
  vpc_id      = aws_vpc.my-vpc.id
  tags = {
    name = "my-vpc-default-sg"
  }
  ingress {
    description = "allow inbound traffic for default ssh port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "my-vpc-web-application-sg" {
  description = "all inbound traffic for default ports and all outbound traffic"
  name        = "my-vpc-web-application-sg"
  vpc_id      = aws_vpc.my-vpc.id
  tags = {
    name = "my-vpc-web-application-sg"
  }
  ingress {
    description = "allow inbound traffic for default port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow inbound traffic for default port 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my-ec2-instance" {
  ami                    = "ami-046eeba8a7f7bbefd"
  instance_type          = "t2.micro"
  key_name               = "awsuser-key"
  availability_zone      = "us-east-1a"
  subnet_id              = aws_subnet.my-vpc-us-east-1a-public-subnet-1.id
  vpc_security_group_ids = [aws_security_group.my-vpc-default-sg.id, aws_security_group.my-vpc-web-application-sg.id]
  user_data              = file("install-httpd.sh")
  tags = {
    name = "my-ec2-instance"
  }
}

resource "aws_eip" "my-vpc-elastic-ip-1" {
  domain     = "vpc"
  instance   = aws_instance.my-ec2-instance.id
  depends_on = [aws_internet_gateway.my-vpc-igw]
  tags = {
    name = "my-vpc-elastic-ip-1"
  }
}

