aws_region          = "us-east-1"
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"
public_subnet_az    = "us-east-1a"
private_subnet_az   = "us-east-1b"
key_name            = "my-key"
private_key_path    = "key_local.pem"
ami_id              = "ami-0b72821e2f351e396"
instance_type       = "t2.medium"
user_data_path      = "user_data.txt"
allowed_cidr_blocks = ["0.0.0.0/0"]