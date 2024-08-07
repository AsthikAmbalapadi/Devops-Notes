variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_az" {
  description = "Availability zone for the public subnet"
  type        = string
  default     = "us-east-1a"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_az" {
  description = "Availability zone for the private subnet"
  type        = string
  default     = "us-east-1b"
}

variable "key_name" {
  description = "The name of the key pair"
  type        = string
  default     = "my-key"
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0b72821e2f351e396"
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = "t2.medium"
}

variable "private_key_path" {
  description = "Path to store the private key file"
  type        = string
  default     = "key_local.pem"
}

variable "user_data_path" {
  description = "Path to the user data file"
  type        = string
  default     = "user_data.txt"
}

variable "allowed_cidr_blocks" {
  description = "List of allowed CIDR blocks for security group rules"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}