aws_region          = "us-east-1"
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"
public_subnet_az    = "us-east-1a"
private_subnet_az   = "us-east-1b"
allowed_cidr_blocks = ["0.0.0.0/0"]
key_name            = "key"
private_key_path    = "C:/Users/Asthik Creak/Desktop/Testing/Terraform/key_local.pem"
ami_id              = "ami-0b72821e2f351e396"
instance_type       = "t2.medium"
user_data_path      = "C:/Users/Asthik Creak/Desktop/Testing/Terraform/user_data.txt"