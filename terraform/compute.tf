data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"]

  filter {
    name   = "name"
    values = ["debian-13-arm64-*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-key"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "controller" {
  count                  = var.master_count
  ami                    = data.aws_ami.debian.id
  instance_type          = var.master_instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private.id]
  key_name               = aws_key_pair.main.key_name

  tags = { Name = "${var.project_name}-controller-${count.index}", Project = var.project_name, Role = "controller" }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.debian.id
  instance_type          = var.web_instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.public.id]
  key_name               = aws_key_pair.main.key_name
  source_dest_check      = false

  tags = { Name = "${var.project_name}-web", Project = var.project_name, Role = "worker" }
}

resource "aws_instance" "db" {
  ami                    = data.aws_ami.debian.id
  instance_type          = var.db_instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private.id]
  key_name               = aws_key_pair.main.key_name
  source_dest_check      = false

  tags = { Name = "${var.project_name}-db", Project = var.project_name, Role = "worker" }
}
