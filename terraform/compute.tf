data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"]

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"] # TODO: Migrate to newer debian once working
  }

  filter {
    name   = "architecture"
    values = ["x86_64"] # TODO: Once working move to arm
  }
}

resource "aws_key_pair" "main" {
  key_name   = "cluster-key"
  public_key = file(var.public_key_path)
}

# TODO: move to private subnet + security group once VPN is set up
resource "aws_instance" "controller" {
  count                  = var.master_count
  ami                    = data.aws_ami.debian.id
  instance_type          = var.master_instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.public.id]
  key_name               = aws_key_pair.main.key_name

  tags = { Name = "cluster-controller-${count.index}" }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.debian.id
  instance_type          = var.web_instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.public.id]
  key_name               = aws_key_pair.main.key_name

  tags = { Name = "cluster-web" }
}

resource "aws_instance" "db" {
  ami                    = data.aws_ami.debian.id
  instance_type          = var.db_instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private.id]
  key_name               = aws_key_pair.main.key_name

  tags = { Name = "cluster-db" }
}
