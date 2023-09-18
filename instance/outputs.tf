output "vm-dns" {
  value = aws_instance.web.private_dns
}

output "vm-ip" {
  value = aws_instance.web.private_ip
}