resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "main-vpc-${var.random_suffix}"
  })
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet_cidr_blocks)

  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  availability_zone = element(sort(data.aws_availability_zones.available.names), count.index)
  vpc_id            = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "subnet-${count.index}-${var.random_suffix}"
  })
}

resource "aws_security_group" "wg" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "wg-sg-${var.random_suffix}"
  })
}

resource "aws_security_group_rule" "allow_self_in" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  security_group_id = aws_security_group.wg.id
  self              = true
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "main-igw-${var.random_suffix}"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.tags, {
    Name = "public-route-table-${var.random_suffix}"
  })
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr_blocks)

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "tls_private_key" "deployer" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  public_key = tls_private_key.deployer.public_key_openssh
}