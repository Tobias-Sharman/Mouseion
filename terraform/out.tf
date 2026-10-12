output "gateway_public_ip" {
  value = aws_eip.gateway.public_ip
}

output "gateway_tunnel_address" {
  value = "${cidrhost(var.vpn_tunnel_cidr, 1)}/${split("/", var.vpn_tunnel_cidr)[1]}"
}

output "vpn_tunnel_cidr" {
  value = var.vpn_tunnel_cidr
}

output "vpc_cidr" {
  value = var.vpc_cidr
}

output "private_subnet_cidr" {
  value = aws_subnet.private.cidr_block
}

output "vpc_dns_resolver" {
  value = cidrhost(var.vpc_cidr, 2)
}

output "apiserver_endpoint" {
  value = aws_lb.apiserver.dns_name
}

output "node_private_ips" {
  value = { for node in aws_instance.node : node.tags.Name => node.private_ip }
}

output "aws_region" {
  value = var.aws_region
}

output "cluster_name" {
  value = var.cluster_name
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "oidc_issuer_url" {
  value = local.oidc_issuer_url
}

output "oidc_bucket" {
  value = aws_s3_bucket.oidc.id
}

output "irsa_role_arns" {
  value = { for name, role in aws_iam_role.irsa : name => role.arn }
}

output "website_certificate_arn" {
  value = local.dns_enabled ? aws_acm_certificate.website[0].arn : null
}

output "domain_name_servers" {
  value = local.dns_enabled ? aws_route53_zone.public[0].name_servers : null
}
