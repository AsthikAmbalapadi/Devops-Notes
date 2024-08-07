# Specify the AWS provider and region
provider "aws" {
  region = var.aws_region
}

# Create a VPC with a specified CIDR block
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "My VPC"
  }
}

# Create a public subnet within the VPC
resource "aws_subnet" "public_subnet" {
  vpc_id             = aws_vpc.vpc.id
  cidr_block         = var.public_subnet_cidr
  availability_zone  = var.public_subnet_az
  tags = {
    Name = "Public Subnet"
  }
}

# Create a private subnet within the VPC
resource "aws_subnet" "private_subnet" {
  vpc_id             = aws_vpc.vpc.id
  cidr_block         = var.private_subnet_cidr
  availability_zone  = var.private_subnet_az
  tags = {
    Name = "Private Subnet"
  }
}

# Create an Internet Gateway for the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "my IGW"
  }
}

# Allocate an Elastic IP for the NAT Gateway
resource "aws_eip" "elastic_ip" {
  domain = "vpc"
  tags = {
    Name = "Elastic IP 1"
  }
}

# Create a NAT Gateway in the public subnet
resource "aws_nat_gateway" "public_nat" {
  subnet_id     = aws_subnet.public_subnet.id
  allocation_id = aws_eip.elastic_ip.id
  tags = {
    Name = "NAT Gateway"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Create a public route table for the VPC
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

# Create a private route table for the VPC
resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.public_nat.id
  }

  tags = {
    Name = "Private Route Table"
  }
}

# Associate the public route table with the public subnet
resource "aws_route_table_association" "public_subnet_route" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route.id
}

# Associate the private route table with the private subnet
resource "aws_route_table_association" "private_subnet_route" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route.id
}

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