# VPC
resource "aws_vpc" "default" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "Name" = "default"
  }
}

# インターネットゲートウェイ
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

# パブリックネットワーク-マルチAZ
# パブリックサブネット01
resource "aws_subnet" "public_01" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"
}

resource "aws_route_table_association" "public_01" {
  subnet_id      = aws_subnet.public_01.id
  route_table_id = aws_route_table.public.id
}

# パブリックサブネット02
resource "aws_subnet" "public_02" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"
}

resource "aws_route_table_association" "public_02" {
  subnet_id      = aws_subnet.public_02.id
  route_table_id = aws_route_table.public.id
}

# パブリックネットワーク用ルートテーブル
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.default.id
  destination_cidr_block = "0.0.0.0/0"
}

# プライベートネットワーク-マルチAZ
# プライベートサブネット01
resource "aws_subnet" "private_01" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.65.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false
}

resource "aws_route_table_association" "private_01" {
  subnet_id      = aws_subnet.private_01.id
  route_table_id = aws_route_table.private_01.id
}

resource "aws_route_table" "private_01" {
  vpc_id = aws_vpc.default.id
}

# NATゲートウェイ01
resource "aws_nat_gateway" "nat_gateway_01" {
  allocation_id = aws_eip.nat_gateway_01.id
  subnet_id     = aws_subnet.public_01.id
  depends_on    = [aws_internet_gateway.default]
}

resource "aws_eip" "nat_gateway_01" {
  vpc        = true
  depends_on = [aws_internet_gateway.default]
}

resource "aws_route" "private_01" {
  route_table_id         = aws_route_table.private_01.id
  nat_gateway_id         = aws_nat_gateway.nat_gateway_01.id
  destination_cidr_block = "0.0.0.0/0"
}

# プライベートサブネット02
resource "aws_subnet" "private_02" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.66.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false
}

resource "aws_route_table_association" "private_02" {
  subnet_id      = aws_subnet.private_02.id
  route_table_id = aws_route_table.private_02.id
}

resource "aws_route_table" "private_02" {
  vpc_id = aws_vpc.default.id
}

# NATゲートウェイ02
resource "aws_nat_gateway" "nat_gateway_02" {
  allocation_id = aws_eip.nat_gateway_02.id
  subnet_id     = aws_subnet.public_02.id
  depends_on    = [aws_internet_gateway.default]
}

resource "aws_eip" "nat_gateway_02" {
  vpc        = true
  depends_on = [aws_internet_gateway.default]
}

resource "aws_route" "private_02" {
  route_table_id         = aws_route_table.private_02.id
  nat_gateway_id         = aws_nat_gateway.nat_gateway_02.id
  destination_cidr_block = "0.0.0.0/0"
}
