resource "aws_instance" "gateway" {
  ami                    = data.aws_ami.debian[local.instance_arch[var.gateway_instance_type]].id
  instance_type          = var.gateway_instance_type
  subnet_id              = aws_subnet.public["primary"].id
  vpc_security_group_ids = [aws_security_group.gateway.id]
  key_name               = aws_key_pair.main.key_name
  source_dest_check      = false

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_type = "gp3"
    encrypted   = true
  }

  tags = { Name = "${var.project_name}-gateway", Role = "gateway" }
}

resource "aws_eip" "gateway" {
  instance   = aws_instance.gateway.id
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = { Name = "${var.project_name}-eip-gateway" }
}
