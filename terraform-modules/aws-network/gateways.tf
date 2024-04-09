resource "aws_internet_gateway" "internet_gateway" {
  depends_on = [aws_subnet.public_subnets, aws_subnet.private_subnets]

  tags = {
    Name = "${var.project_name}-${var.env}-internet-gateway"
  }
}

resource "aws_internet_gateway_attachment" "InternetGatewayAttachment" {
  internet_gateway_id = aws_internet_gateway.internet_gateway.id
  vpc_id              = aws_vpc.vpc.id

  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_eip" "nat_eip" {
  domain   = "vpc"

  depends_on = [aws_internet_gateway_attachment.InternetGatewayAttachment]

  tags = {
    Name = "${var.project_name}-${var.env}-nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id

  depends_on = [aws_eip.nat_eip]

  tags = {
    Name = "${var.project_name}-${var.env}-nat-gw"
  }
}