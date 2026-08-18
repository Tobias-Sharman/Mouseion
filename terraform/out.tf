output "apiserver_internal_address" {
  value = local.apiserver_internal_address
}

output "apiserver_internal_san" {
  value = local.apiserver_internal_san
}

output "controller_private_ips" {
  value = {
    for i in range(var.master_count) :
    aws_instance.controller[i].tags.Name => aws_instance.controller[i].private_ip
  }
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
  value = join(",", [
    for i in range(var.master_count) :
    "${aws_instance.controller[i].tags.Name}=https://${aws_instance.controller[i].private_ip}:2380"
  ])
}

output "pod_cidr" {
  value = var.pod_cidr
}

output "worker_pod_cidrs" {
  value = local.worker_pod_cidrs
}

output "vpn_public_ip" {
  value = aws_eip.vpn.public_ip
}

output "vpn_gateway_tunnel_ip" {
  value = cidrhost(var.vpn_tunnel_cidr, 1)
}

output "vpc_cidr" {
  value = var.vpc_cidr
}

output "vpc_dns_resolver" {
  value = cidrhost(var.vpc_cidr, 2)
}
