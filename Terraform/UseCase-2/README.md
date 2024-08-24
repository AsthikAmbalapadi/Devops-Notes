### **Introduction** 🌟

In modern infrastructure management with Terraform, organizing your code into multiple files is a common best practice. This approach not only enhances readability and maintainability but also promotes a more scalable and modular infrastructure setup. In this use case, we have split the Terraform configuration into three distinct files:

1. **`project.tf`**: Contains the core infrastructure resources.
2. **`terraform.tfvars`**: Provides values for the variables used in `project.tf`.
3. **`variable.tf`**: Defines the variables used in the Terraform configuration.

This separation helps in managing different aspects of your infrastructure setup efficiently. Let’s delve into each file to understand their purpose and the detailed implementation.

**Use Case for Bifurcation** 🔄:
Separating this file into multiple parts allows for clear organization of different aspects of infrastructure management. This modular approach:

1. **Improves Readability** 📚: Each section is focused on a specific aspect, making it easier to understand and manage.
2. **Facilitates Collaboration** 🤝: Different team members can work on different files without conflicts.
3. **Enables Reusability** 🔁: Modular components can be reused across different projects or environments.

---

### **File 1: `project.tf`** 🌍

This file is the heart of your Terraform configuration. It defines the core resources and their relationships.

```hcl
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
```

**Detailed Explanation** 🧐

- **Provider Configuration** 🌐: Specifies AWS as the cloud provider and sets the region using a variable.
- **VPC** 🌍: Defines a Virtual Private Cloud (VPC) with a specified CIDR block, providing a private network space.
- **Public and Private Subnets** 🌳: Creates public and private subnets within the VPC, each in different availability zones for high availability.
- **Internet Gateway (IGW)** 🌐: Allows the VPC to access the internet.
- **NAT Gateway** 🌐: Provides internet access for instances in private subnets by routing traffic through an Elastic IP.
- **Route Tables** 🛤️: Defines routing rules for both public and private subnets, ensuring correct traffic flow.
- **Security Groups** 🔐: Configures inbound and outbound rules for instance traffic, allowing SSH, HTTP, and ICMP while restricting access as needed.
- **Key Pair** 🔑: Generates an SSH key pair for secure access to EC2 instances.
- **EC2 Instance** 🖥️: Launches an EC2 instance in the public subnet using the specified AMI and instance type.

**Best Practices** 🏆:
- **Modular Design**: Split configurations into logical sections for better readability and maintainability.
- **Security**: Securely handle sensitive data such as private keys and avoid hardcoding credentials.

---

### **File 2: `terraform.tfvars`** 📋

This file provides specific values for the variables defined in `variable.tf`, enabling flexible and customizable Terraform configurations.

```hcl
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
```

**Detailed Explanation** 🧐

- **Variable Values** 🎯: Assigns values to the variables used in `project.tf`, allowing for different configurations without altering the core code.
- **Paths and Identifiers** 🛠️: Specifies paths for storing keys and user data files, and provides identifiers for the AWS resources.

**Best Practices** 🏆:
- **Separation of Concerns**: Keep variable values in a separate file to isolate them from the core configuration, making it easier to update values without modifying the main code.
- **Sensitive Data Handling**: Avoid exposing sensitive data in version-controlled files; use secure storage solutions.

---

### **File 3: `variable.tf`** 🔧

Defines all the variables used in the Terraform configuration, including their types and default values.

```hcl
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
```

**Detailed Explanation** 🧐

- **Variable Definitions** 📜: Specifies the variables used across the Terraform files, including their types, descriptions, and default values.
- **Customization** 🎨: Allows for easy customization of the infrastructure setup by changing the variable values without modifying the core configuration.

**Best Practices** 🏆:
- **Documentation**: Provide clear descriptions for each variable to make it easier for users to understand their purpose.
- **Defaults**: Set sensible default values to simplify initial setup and provide a baseline configuration.

---

### **Summary** 📝

In this use case, we have effectively divided the Terraform configuration into multiple files to achieve a more organized and maintainable infrastructure setup. The separation into `project.tf`, `terraform.tfvars`, and `variable.tf` enhances clarity and allows for easier management of different aspects of the configuration. 

By adopting these best practices and utilizing the separation of concerns, you can maintain a more scalable and adaptable infrastructure setup. Always ensure that sensitive information is handled securely and follow best practices for modular design and variable management.

---