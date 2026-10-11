resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.project_name}-vpc" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "${var.project_name}-igw" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 1, 0)
  map_public_ip_on_launch = true

  tags = { Name = "${var.project_name}-subnet-public" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  route {
    cidr_block           = var.vpn_tunnel_cidr
    network_interface_id = aws_instance.vpn.primary_network_interface_id
  }

  route {
    cidr_block           = local.worker_pod_cidrs[aws_instance.db.tags.Name]
    network_interface_id = aws_instance.db.primary_network_interface_id
  }

  tags = { Name = "${var.project_name}-rt-public" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 1, 1)
  map_public_ip_on_launch = false

  tags = { Name = "${var.project_name}-subnet-private" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block           = var.vpn_tunnel_cidr
    network_interface_id = aws_instance.vpn.primary_network_interface_id
  }

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_instance.vpn.primary_network_interface_id
  }

  route {
    cidr_block           = local.worker_pod_cidrs[aws_instance.web.tags.Name]
    network_interface_id = aws_instance.web.primary_network_interface_id
  }

  tags = { Name = "${var.project_name}-rt-private" }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

locals {
  worker_pod_cidrs = {
    (aws_instance.web.tags.Name) = cidrsubnet(var.pod_cidr, 8, 1) # 10.206.1.0/24
    (aws_instance.db.tags.Name)  = cidrsubnet(var.pod_cidr, 8, 2) # 10.206.2.0/24
  }
}
