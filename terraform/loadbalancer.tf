resource "aws_lb" "apiserver" {
  count              = var.master_count > 1 ? 1 : 0
  name               = "${var.project_name}-apiserver"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.public.id] # TODO: VPN

  tags = { Name = "${var.project_name}-lb-apiserver" }
}

resource "aws_lb_target_group" "apiserver" {
  count       = var.master_count > 1 ? 1 : 0
  name        = "${var.project_name}-apiserver"
  port        = 6443
  protocol    = "TCP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    protocol = "TCP"
    port     = "6443"
  }

  tags = { Name = "${var.project_name}-tg-apiserver" }
}

resource "aws_lb_target_group_attachment" "apiserver" {
  count            = var.master_count > 1 ? var.master_count : 0
  target_group_arn = aws_lb_target_group.apiserver[0].arn
  target_id        = aws_instance.controller[count.index].id
  port             = 6443
}

resource "aws_lb_listener" "apiserver" {
  count             = var.master_count > 1 ? 1 : 0
  load_balancer_arn = aws_lb.apiserver[0].arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.apiserver[0].arn
  }
}

locals {
  apiserver_external_address = var.master_count > 1 ? aws_lb.apiserver[0].dns_name : aws_instance.controller[0].public_ip
  apiserver_internal_address = var.master_count > 1 ? aws_lb.apiserver[0].dns_name : aws_instance.controller[0].private_ip
  apiserver_external_san     = var.master_count > 1 ? "DNS:${aws_lb.apiserver[0].dns_name}" : "IP:${aws_instance.controller[0].public_ip}"
  apiserver_internal_san     = var.master_count > 1 ? "DNS:${aws_lb.apiserver[0].dns_name}" : "IP:${aws_instance.controller[0].private_ip}"
}
