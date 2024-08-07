# Create a private subnet within the VPC
resource "aws_subnet" "private_subnet" {
  vpc_id             = aws_vpc.vpc.id
  cidr_block         = var.private_subnet_cidr
  availability_zone  = var.private_subnet_az
  tags = {
    Name = "Private Subnet"
  }
}