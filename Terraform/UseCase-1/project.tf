# Specify the AWS provider and region
provider "aws" {
  region = "us-east-1"
}

# Create a VPC with a specified CIDR block
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "My VPC"
  }
}

# Create a public subnet within the VPC
resource "aws_subnet" "public_subnet" {
  vpc_id             = aws_vpc.vpc.id
  cidr_block         = "10.0.1.0/24"
  availability_zone  = "us-east-1a"
  tags = {
    Name = "Public Subnet"
  }
}

# Create a private subnet within the VPC
resource "aws_subnet" "private_subnet" {
  vpc_id             = aws_vpc.vpc.id
  cidr_block         = "10.0.2.0/24"
  availability_zone  = "us-east-1b"
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
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow all ICMP from anywhere"
    from_port   = -1  # ICMP doesn't use ports, so use -1
    to_port     = -1  # ICMP doesn't use ports, so use -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
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
  key_name   = "key"
  public_key = tls_private_key.my_key.public_key_openssh

  tags = {
    Name = "Generated Key"
  }
}

# If the Private Key to be stored locally
resource "local_file" "private_key_pem" {
  content  = tls_private_key.my_key.private_key_pem
  filename = "C:/Users/Asthik Creak/Desktop/Testing/Terraform/project_1/key_local.pem"
  depends_on = [aws_key_pair.generated_key]
}

# Create an EC2 instance in the public subnet using the generated key pair
resource "aws_instance" "webserver" {
  ami                       = "ami-0b72821e2f351e396" # Amazon Linux 2023 AMI
  instance_type             = "t2.medium"
  key_name                  = aws_key_pair.generated_key.key_name
  subnet_id                 = aws_subnet.public_subnet.id
  security_groups           = [aws_security_group.allow_ssh_http_icmp.id]
  associate_public_ip_address = true
  user_data                 = file("C:/Users/Asthik Creak/Desktop/Testing/Terraform/user_data.txt")

  root_block_device {
    volume_type = "gp3"
    volume_size = 10
  }

  tags = {
    Name = "Webserver"
  }
}


/* Another way for writing Security group rules
resource "aws_security_group" "allow_ssh_tcp" {
  name        = "Allow SSH & TCP"
  description = "Allow SSH & TCP traffic to CIDR blocks"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "SSH & TCP"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_ssh_tcp.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_tcp_ipv4" {
  security_group_id = aws_security_group.allow_ssh_tcp.id
  cidr_ipv4         = "0.0.0.0/0" 
  from_port         = 0
  ip_protocol       = "tcp"
  to_port           = 65535
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound_traffic_ipv4" {
  security_group_id = aws_security_group.allow_ssh_tcp.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
*/


/*
# Output the private key
output "private_key_pem" {
  value     = tls_private_key.my_key.private_key_pem
  sensitive = true
}
*/