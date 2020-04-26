//Resources:
// VPC + public & private subnets
// availability zones
data "aws_availability_zones" "zones" {}

// vpc
resource "aws_vpc" "main" {
  cidr_block           = var.vcp_ip_range
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project}-vpc"
    Env  = var.env
  }
}

// private subnet
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vcp_ip_range, 8, length(data.aws_availability_zones.zones.names) + 1)
  availability_zone       = element(data.aws_availability_zones.zones.names, 0)
  tags = {
    Name = "${var.project}-private-subnet"
    Env  = var.env
  }
}

// public subnets
resource "aws_subnet" "public" {
  count                   = length(data.aws_availability_zones.zones.names)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vcp_ip_range, 8, count.index)
  availability_zone       = element(data.aws_availability_zones.zones.names, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-public-subnet-${count.index}}"
    Env  = var.env
  }
}
// Extra public subnet for alb (Making it cheaper -> NAT)


// IGW for the public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project}-igw"
    Env  = var.env
  }
}

# Route the public subnet traffic through the IGW
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Create a NAT gateway with an EIP for each private subnet to get internet connectivity
resource "aws_eip" "gw" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "${var.project}-eip"
    Env  = var.env
  }
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.gw.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  depends_on    = [aws_internet_gateway.igw]
}

// Create a new route table for the private subnets
// And make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.id
  }
  tags = {
    Name = var.project
    Env  = var.env
  }
}

resource "aws_route_table" "public" {
  count = length(data.aws_availability_zones.zones.names)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
    tags = {
    Name = var.project
    Env  = var.env
  }
}

// Explicitely associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  count          = length(data.aws_availability_zones.zones.names)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public.*.id, count.index)
}



