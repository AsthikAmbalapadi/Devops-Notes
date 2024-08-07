# Create a VPC with a specified CIDR block
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "My VPC"
  }
}