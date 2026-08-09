resource "aws_security_group" "public" {
  name   = "cluster-public"
  vpc_id = aws_vpc.main.id

  tags = { Name = "cluster-sg-public" }
}

resource "aws_security_group_rule" "public_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.ssh_source_cidr]
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_apiserver" {
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = [var.ssh_source_cidr]
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group" "private" {
  name   = "cluster-private"
  vpc_id = aws_vpc.main.id

  tags = { Name = "cluster-sg-private" }
}

resource "aws_security_group_rule" "private_db_from_public" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.public.id
  security_group_id        = aws_security_group.private.id
}

resource "aws_security_group_rule" "private_ssh_from_public" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.public.id
  security_group_id        = aws_security_group.private.id
}

resource "aws_security_group_rule" "private_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.private.id
}
