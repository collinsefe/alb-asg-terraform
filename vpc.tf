resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.name_prefix}-project-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnets["a"].cidr
  availability_zone = var.subnets["a"].az

  tags = {
    Name = "${var.name_prefix}-subnet-2a"
  }
}


resource "aws_subnet" "foo" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnets["b"].cidr
  availability_zone = var.subnets["b"].az

  tags = {
    Name = "${var.name_prefix}-subnet-2b"
  }
}


resource "aws_subnet" "bar" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnets["c"].cidr
  availability_zone = var.subnets["c"].az

  tags = {
    Name = "${var.name_prefix}-subnet-2c"
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.name_prefix
  }
}


#Create a Route Table for Public Subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.bar.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_3" {
  subnet_id      = aws_subnet.foo.id
  route_table_id = aws_route_table.public_rt.id
}
