# Create an EC2 instance in the public subnet using the generated key pair or reuse existing key pair
resource "aws_instance" "webserver" {
  ami                       = var.ami_id
  instance_type             = var.instance_type
  key_name                  = aws_key_pair.generated_key.key_name
  subnet_id                 = aws_subnet.public_subnet.id
  security_groups           = [aws_security_group.allow_ssh_http_icmp.id]
  associate_public_ip_address = true
  user_data                 = file(var.user_data_path)

  root_block_device {
    volume_type = "gp3"
    volume_size = 10
  }

  tags = {
    Name = "Webserver"
  }
}