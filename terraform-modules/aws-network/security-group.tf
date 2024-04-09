resource "aws_security_group" "security_group" {
  name   =  "${var.project_name}-${var.env}-sec-grp"
  vpc_id = aws_vpc.vpc.id
  description = "Allow TLS inbound and outbound traffics"

  ingress = [{
    description      = "Allow HTTPS"
    protocol         = local.tcp_protocol
    from_port        = local.https_port
    to_port          = local.https_port
    cidr_blocks      = [local.all_address]
    ipv6_cidr_blocks = null
    prefix_list_ids  = []
    security_groups  = []
    self             = false
    },
    {
    description      = "Allow HTTP"
    protocol         = local.tcp_protocol
    from_port        = local.http_port
    to_port          = local.http_port
    cidr_blocks      = [local.all_address]
    ipv6_cidr_blocks = null
    prefix_list_ids  = []
    security_groups  = []
    self             = false
    },
    {
    description      = "Allow SSH"
    protocol         = local.tcp_protocol
    from_port        = local.ssh_port
    to_port          = local.ssh_port
    cidr_blocks      = [local.all_address]
    ipv6_cidr_blocks = null
    prefix_list_ids  = []
    security_groups  = []
    self             = false
    }
  ]

  egress = [
    {
    description      = "Allow all outbound traffic"
    protocol         = local.any_protocol
    from_port        = local.any_port
    to_port          = local.any_port
    cidr_blocks      = [local.all_address]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    security_groups  = []
    self             = false
    }
  ]

  depends_on = [aws_route.private_internet_route]

  tags = {
    Name = "Allow TLS for ${var.project_name}-${var.env}"
  }
}