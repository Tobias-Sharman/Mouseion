data "http" "admin_ip" {
  url = "https://checkip.amazonaws.com"
}

resource "aws_security_group" "gateway" {
  name   = "${var.project_name}-gateway"
  vpc_id = aws_vpc.main.id

  tags = { Name = "${var.project_name}-sg-gateway" }
}

resource "aws_vpc_security_group_ingress_rule" "gateway_wireguard" {
  security_group_id = aws_security_group.gateway.id
  ip_protocol       = "udp"
  from_port         = 51820
  to_port           = 51820
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "gateway_ssh_admin" {
  security_group_id = aws_security_group.gateway.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "${chomp(data.http.admin_ip.response_body)}/32"
}

resource "aws_vpc_security_group_ingress_rule" "gateway_from_private_subnet" {
  security_group_id = aws_security_group.gateway.id
  ip_protocol       = "-1"
  cidr_ipv4         = aws_subnet.private.cidr_block
}

resource "aws_vpc_security_group_egress_rule" "gateway_all" {
  security_group_id = aws_security_group.gateway.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "node" {
  name   = "${var.project_name}-node"
  vpc_id = aws_vpc.main.id

  tags = {
    Name                                        = "${var.project_name}-sg-node"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_vpc_security_group_ingress_rule" "node_from_nodes" {
  security_group_id            = aws_security_group.node.id
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.node.id
}

resource "aws_vpc_security_group_ingress_rule" "node_ssh_tunnel" {
  security_group_id = aws_security_group.node.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.vpn_tunnel_cidr
}

resource "aws_vpc_security_group_egress_rule" "node_all" {
  security_group_id = aws_security_group.node.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "controller" {
  name   = "${var.project_name}-controller"
  vpc_id = aws_vpc.main.id

  tags = { Name = "${var.project_name}-sg-controller" }
}

resource "aws_vpc_security_group_ingress_rule" "controller_apiserver_lb" {
  security_group_id            = aws_security_group.controller.id
  ip_protocol                  = "tcp"
  from_port                    = 6443
  to_port                      = 6443
  referenced_security_group_id = aws_security_group.apiserver_lb.id
}

resource "aws_vpc_security_group_ingress_rule" "controller_apiserver_tunnel" {
  security_group_id = aws_security_group.controller.id
  ip_protocol       = "tcp"
  from_port         = 6443
  to_port           = 6443
  cidr_ipv4         = var.vpn_tunnel_cidr
}

resource "aws_security_group" "apiserver_lb" {
  name   = "${var.project_name}-apiserver-lb"
  vpc_id = aws_vpc.main.id

  tags = { Name = "${var.project_name}-sg-apiserver-lb" }
}

resource "aws_vpc_security_group_ingress_rule" "apiserver_lb_from_nodes" {
  security_group_id            = aws_security_group.apiserver_lb.id
  ip_protocol                  = "tcp"
  from_port                    = 6443
  to_port                      = 6443
  referenced_security_group_id = aws_security_group.node.id
}

resource "aws_vpc_security_group_ingress_rule" "apiserver_lb_tunnel" {
  security_group_id = aws_security_group.apiserver_lb.id
  ip_protocol       = "tcp"
  from_port         = 6443
  to_port           = 6443
  cidr_ipv4         = var.vpn_tunnel_cidr
}

resource "aws_vpc_security_group_egress_rule" "apiserver_lb_to_controllers" {
  security_group_id            = aws_security_group.apiserver_lb.id
  ip_protocol                  = "tcp"
  from_port                    = 6443
  to_port                      = 6443
  referenced_security_group_id = aws_security_group.controller.id
}
