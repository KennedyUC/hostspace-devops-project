data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public_subnets" {
  count = var.subnet_count

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, var.subnet_bits, count.index)
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true

  depends_on = [aws_vpc.vpc]

  tags = {
    Name = "${var.project_name}-${var.env}-public-subnet"
  }
}

resource "aws_subnet" "private_subnets" {
  count = var.subnet_count

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, var.subnet_bits, count.index + var.subnet_count)
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = false

  depends_on = [aws_vpc.vpc]

  tags = {
    Name = "${var.project_name}-${var.env}-private-subnet"
  }
}