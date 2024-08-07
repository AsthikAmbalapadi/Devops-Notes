# Create a NAT Gateway in the public subnet
resource "aws_nat_gateway" "public_nat" {
  subnet_id     = aws_subnet.public_subnet.id
  allocation_id = aws_eip.elastic_ip.id
  tags = {
    Name = "NAT Gateway"
  }

  depends_on = [aws_internet_gateway.igw]
}