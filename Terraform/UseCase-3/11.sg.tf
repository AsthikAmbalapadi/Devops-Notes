# Create a security group allowing SSH, HTTP, and ICMP traffic
resource "aws_security_group" "allow_ssh_http_icmp" {
  name        = "Allow SSH, HTTP & ICMP"
  description = "Allow SSH, HTTP & ICMP traffic to CIDR blocks"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    description = "Allow all ICMP from anywhere"
    from_port   = -1  # ICMP doesn't use ports, so use -1
    to_port     = -1  # ICMP doesn't use ports, so use -1
    protocol    = "icmp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # "-1" means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SSH, HTTP & ICMP"
  }
}