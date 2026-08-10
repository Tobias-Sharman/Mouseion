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
