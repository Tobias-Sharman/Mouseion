data "http" "admin_ip" {
  url = "https://checkip.amazonaws.com"
}

resource "aws_security_group" "vpn" {
  name   = "${var.project_name}-vpn"
  vpc_id = aws_vpc.main.id

  tags = { Name = "${var.project_name}-sg-vpn" }
}

resource "aws_security_group_rule" "vpn_wireguard" {
  type              = "ingress"
  from_port         = 51820
  to_port           = 51820
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.vpn.id
}

resource "aws_security_group_rule" "vpn_routed_traffic" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.vpn.id
}

resource "aws_security_group_rule" "vpn_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.admin_ip.response_body)}/32"]
  security_group_id = aws_security_group.vpn.id
}

resource "aws_security_group_rule" "vpn_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.vpn.id
}

resource "aws_instance" "vpn" {
  ami                    = data.aws_ami.debian.id
  instance_type          = var.vpn_instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.vpn.id]
  key_name               = aws_key_pair.main.key_name
  source_dest_check      = false

  tags = { Name = "${var.project_name}-vpn", Project = var.project_name, Role = "vpn" }
}

resource "aws_eip" "vpn" {
  instance = aws_instance.vpn.id
  domain   = "vpc"

  tags = { Name = "${var.project_name}-eip-vpn" }
}
