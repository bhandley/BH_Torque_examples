output "vm-dns" {
  value = aws_instance.web.public_dns
}

output "vm-ip" {
  value = aws_instance.web.public_ip
}