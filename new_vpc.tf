# 1 Create VPC
resource "aws_vpc" "hele-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {

    Name = "HeleVPC"
  }
}
# 2 Create Pubic Subnet
resource "aws_subnet" "public-sn-01" {
  vpc_id                  = aws_vpc.hele-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  depends_on              = [aws_internet_gateway.router]

  tags = {

    Name = "Public-Subnet-1a"
  }
}

resource "aws_subnet" "public-sn-02" {
  vpc_id                  = aws_vpc.hele-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {

    Name = "Public-Subnet-2b"
  }
}

# 3 Create Privete Subnet for ec2-instances
resource "aws_subnet" "private-sn-01" {
  vpc_id                  = aws_vpc.hele-vpc.id
  cidr_block              = "10.0.22.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {

    Name = "Instances-Subnet-1a"
  }
}

resource "aws_subnet" "private-sn-02" {
  vpc_id                  = aws_vpc.hele-vpc.id
  cidr_block              = "10.0.44.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {

    Name = "Instance-Subnet-2b"
  }
}

# 4 Create and Attach IGW to the VPC
resource "aws_internet_gateway" "router" {
  vpc_id = aws_vpc.hele-vpc.id

  tags = {
    Name = "HeleGateway"
  }
}

# 5 Create public Route Table > Route to IGW > Assoc with Public Subnet
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.hele-vpc.id

  # 6 Create route > target IGW
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.router.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

# 7 Associate Public Route Tabls
resource "aws_route_table_association" "az-public-a" {
  subnet_id      = aws_subnet.public-sn-01.id
  route_table_id = aws_route_table.public-rt.id
}


resource "aws_route_table_association" "az-public-b" {
  subnet_id      = aws_subnet.public-sn-02.id
  route_table_id = aws_route_table.public-rt.id
}

# 8 Allocate EIP for NAT Gateway 
resource "aws_eip" "hele-eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.router]

}
# 9 Create NAT Gateway > Public Subnet 
resource "aws_nat_gateway" "hele-nat" {
  allocation_id = aws_eip.hele-eip.id
  subnet_id     = aws_subnet.public-sn-01.id
  depends_on    = [aws_internet_gateway.router]

  tags = {
    Name = "HeleNat"
  }
}

# 10 Create private Route Table > route to NAT > assoc with Private Subnet 
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.hele-vpc.id

  # 11 Create route > 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.hele-nat.id
  }

  tags = {
    Name = "Privae Route Table"
  }
}

# 12 Associate Private Route Tables
resource "aws_route_table_association" "az-private-a" {
  subnet_id      = aws_subnet.private-sn-01.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "az-private-b" {
  subnet_id      = aws_subnet.private-sn-02.id
  route_table_id = aws_route_table.private-rt.id
}