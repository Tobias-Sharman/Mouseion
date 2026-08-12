output "controller_public_ip" {
  value = aws_instance.controller[*].public_ip
}

output "web_public_ip" {
  value = aws_instance.web.public_ip
}

output "db_private_ip" {
  value = aws_instance.db.private_ip
}

output "apiserver_external_address" {
  value = local.apiserver_external_address
}

output "apiserver_internal_address" {
  value = local.apiserver_internal_address
}

output "apiserver_external_san" {
  value = local.apiserver_external_san
}

output "apiserver_internal_san" {
  value = local.apiserver_internal_san
}

output "controller_private_ips" {
  value = { for i in range(var.master_count) : aws_instance.controller[i].tags.Name => aws_instance.controller[i].private_ip }
}

output "worker_private_ips" {
  value = {
    (aws_instance.web.tags.Name) = aws_instance.web.private_ip
    (aws_instance.db.tags.Name)  = aws_instance.db.private_ip
  }
}

output "etcd_servers" {
  value = join(",", [for i in range(var.master_count) : "https://${aws_instance.controller[i].private_ip}:2379"])
}

output "etcd_initial_cluster" {
  value = join(",", [for i in range(var.master_count) : "${aws_instance.controller[i].tags.Name}=https://${aws_instance.controller[i].private_ip}:2380"])
}
