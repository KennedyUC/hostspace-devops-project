resource "aws_vpc" "vpc" {
  cidr_block            = var.vpc_cidr
  enable_dns_hostnames  = var.enable_vpc_dns

  tags = {
    Name = "${var.project_name}-${var.env}-vpc"
  }
}