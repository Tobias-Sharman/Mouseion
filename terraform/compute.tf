locals {
  nodes = {
    controller-0 = { role = "controller" }
    controller-1 = { role = "controller" }
    controller-2 = { role = "controller" }
    storage-0    = { role = "storage" }
  }
  controllers = { for name, node in local.nodes : name => node if node.role == "controller" }

  instance_types = toset([var.gateway_instance_type, var.node_instance_type])
  debian_arch    = { arm64 = "arm64", x86_64 = "amd64" }
  instance_arch = {
    for type, info in data.aws_ec2_instance_type.all :
    type => one([for arch in info.supported_architectures : arch if contains(keys(local.debian_arch), arch)])
  }
}

data "aws_ec2_instance_type" "all" {
  for_each      = local.instance_types
  instance_type = each.key
}

data "aws_ami" "debian" {
  for_each = toset(values(local.instance_arch))
  owners   = ["136693071363"]

  filter {
    name   = "name"
    values = ["debian-13-${local.debian_arch[each.key]}-${var.debian_ami_release}"]
  }

  filter {
    name   = "architecture"
    values = [each.key]
  }
}

resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-key"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "node" {
  for_each               = local.nodes
  ami                    = data.aws_ami.debian[local.instance_arch[var.node_instance_type]].id
  instance_type          = var.node_instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = each.value.role == "controller" ? [aws_security_group.node.id, aws_security_group.controller.id] : [aws_security_group.node.id]
  key_name               = aws_key_pair.main.key_name
  iam_instance_profile   = each.value.role == "controller" ? aws_iam_instance_profile.controller.name : null

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = {
    Name                                        = "${var.project_name}-${each.key}"
    Role                                        = each.value.role
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}
