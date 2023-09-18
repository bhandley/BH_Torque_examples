
resource "aws_instance" "web" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [var.sg]
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name != "" ? var.key_name : null
  tags = {
    Name = "Test Server quali ${var.sandboxID}"
  }

}