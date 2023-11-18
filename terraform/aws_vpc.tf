resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}${var.vpc_cidr_range}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.project_name}_vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.project_name}_igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.project_name}_public_rt"
  }
}

resource "aws_subnet" "public" {
  for_each                = var.public_subnet_cidr_range
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.vpc_cidr}${each.value.cidr}"
  availability_zone       = "${var.aws_region}${each.value.az}"
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.project_name}_${each.key}"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id

  depends_on = [
    aws_internet_gateway.igw,
  ]

  // Prevent recreation of the route table association on every apply.
  lifecycle {
    ignore_changes = [
      route_table_id,
    ]
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.project_name}_private_rt"
  }
}

resource "aws_subnet" "private" {
  for_each                = var.private_subnet_cidr_range
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.vpc_cidr}${each.value.cidr}"
  availability_zone       = "${var.aws_region}${each.value.az}"
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.project_name}_${each.key}"
  }
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id

  // Prevent recreation of the route table association on every apply.
  lifecycle {
    ignore_changes = [
      route_table_id,
    ]
  }
}