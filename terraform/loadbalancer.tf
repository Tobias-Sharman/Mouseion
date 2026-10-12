resource "aws_lb" "apiserver" {
  name               = "${var.project_name}-apiserver"
  internal           = true
  load_balancer_type = "network"
  subnets            = [aws_subnet.private.id]
  security_groups    = [aws_security_group.apiserver_lb.id]

  tags = { Name = "${var.project_name}-lb-apiserver" }
}

resource "aws_lb_target_group" "apiserver" {
  name        = "${var.project_name}-apiserver"
  port        = 6443
  protocol    = "TCP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"
  # Controllers reach their own apiserver through the LB, which hairpins with client IP preservation on
  preserve_client_ip = false

  health_check {
    protocol = "TCP"
    port     = "6443"
  }

  tags = { Name = "${var.project_name}-tg-apiserver" }
}

resource "aws_lb_target_group_attachment" "apiserver" {
  for_each         = local.controllers
  target_group_arn = aws_lb_target_group.apiserver.arn
  target_id        = aws_instance.node[each.key].id
  port             = 6443
}

resource "aws_lb_listener" "apiserver" {
  load_balancer_arn = aws_lb.apiserver.arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.apiserver.arn
  }
}
