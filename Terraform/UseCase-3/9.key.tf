# Create a new private key
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create a new key pair in AWS using the generated public key
resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.my_key.public_key_openssh

  tags = {
    Name = "Generated Key"
  }
}

# If the Private Key to be stored locally
resource "local_file" "private_key_pem" {
  content  = tls_private_key.my_key.private_key_pem
  filename = var.private_key_path
  depends_on = [aws_key_pair.generated_key]
}