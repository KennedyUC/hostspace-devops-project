resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  depends_on = [aws_nat_gateway.nat_gateway]

  tags = {
    Name = "${var.project_name}-${var.env}-route-table"
  }
}

resource "aws_route_table_association" "public_route_association" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id

  depends_on = [aws_route_table.public_route_table]
}

resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.public_route_table.id
  gateway_id             = aws_internet_gateway.internet_gateway.id
  destination_cidr_block = local.all_address

  depends_on = [aws_route_table_association.public_route_association]
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  depends_on = [aws_route.public_internet_route]

  tags = {
    Name = "${var.project_name}-${var.env}-rt"
  }
}

resource "aws_route_table_association" "private_route_association" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table.id

  depends_on = [aws_route_table.private_route_table]
}

resource "aws_route" "private_internet_route" {
  route_table_id         = aws_route_table.private_route_table.id
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
  destination_cidr_block = local.all_address

  depends_on = [aws_route_table_association.private_route_association]
}