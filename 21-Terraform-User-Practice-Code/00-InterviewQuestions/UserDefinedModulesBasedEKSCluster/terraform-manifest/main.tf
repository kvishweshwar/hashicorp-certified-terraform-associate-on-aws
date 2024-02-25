resource "aws_vpc" "myvpc" {
  cidr_block = var.aws_vpc_cidr_block
  tags = {
    name = "myvpc"
  }
}

resource "aws_subnet" "myvpc-public-subnet" {
  count = length(var.aws_availability_zones)
  vpc_id = aws_vpc.myvpc.id
  availability_zone = var.aws_availability_zones[count.index]
  cidr_block = var.aws_private_subnet_cidr_blocks[count.index]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "myvpc-private-subnet" {
  count = length(var.aws_availability_zones)
  vpc_id = aws_vpc.myvpc.id
  availability_zone = var.aws_availability_zones[count.index]
  cidr_block = var.aws_private_subnet_cidr_blocks[count.index]
}

resource "aws_eip" "myvpc-eip" {
  vpc_id = aws_vpc.myvpc.id
  ## Under construction ##
}

resource "aws_internet_gateway" "myvpc-igw" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_nat_gateway" "myvpc-ngw" {
  count = length(var.aws_availability_zones)
  vpc_id = aws_vpc.myvpc.id
  subnet_id = aws_subnet.myvpc-private-subnet[count.index].id
}

resource "aws_route_table" "myvpc-public-route-table" {
  vpc_id = aws_vpc.myvpc.id
  route {
    destination_address = "0.0.0.0/0"
    internet_gateway_id = aws_internet_gateway.myvpc-igw.id
  }
}

resource "aws_route_table" "myvpc-private-route-table" {
  count = length(var.aws_availability_zones)
  vpc_id = aws_vpc.myvpc.id
  route {
    destination_address = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.myvpc-ngw[count.index].id
  }
}

resource "aws_route_table_association" "myvpc-public-route-table-association" {
  subnet_id = aws_subnet.myvpc-public-route-table.id
  route_table_id = aws_route_table.myvpc-public-route-table.id
}

resource "aws_route_table_association" "myvpc-private-route-table-association" {
  count = length(var.aws_availability_zones)
  subnet_id = aws_subnet.myvpc-public-route-table[count.index].id
  route_table_id = aws_route_table.myvpc-public-route-table[count.index].id
}



resource "aws_aks_cluster" "my-eks-cluster" {
  depends_on = 
}
