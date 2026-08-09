output "controller_public_ip" {
  value = aws_instance.controller[*].public_ip
}

output "web_public_ip" {
  value = aws_instance.web.public_ip
}

output "db_private_ip" {
  value = aws_instance.db.private_ip
}
