module "use_case_3" {
  source = "github.com/AsthikAmbalapadi/Devops-Notes//Terraform/UseCase-3?ref=main"

  # Required variables from use case 3 module
  aws_region          = var.aws_region
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  public_subnet_az    = var.public_subnet_az
  private_subnet_az   = var.private_subnet_az
  allowed_cidr_blocks = var.allowed_cidr_blocks
  key_name            = var.key_name
  private_key_path    = var.private_key_path
  ami_id              = var.ami_id
  instance_type       = var.instance_type
  user_data_path      = var.user_data_path
}