## Introduction 🚀

In this Terraform configuration, we organize the infrastructure code into 13 distinct files. This modular approach is crucial for managing complex infrastructure setups, improving readability, and facilitating scalability. By splitting the configuration into multiple files, we achieve several key benefits:

1. **Modularity**: Each file handles a specific aspect of the infrastructure, allowing for easier updates and management of individual components without affecting the whole configuration.
2. **Readability**: A well-organized structure makes the Terraform codebase easier to navigate and understand, especially as the complexity of the infrastructure increases.
3. **Reusability**: Separating concerns enables you to reuse certain configurations or modules across different projects or environments.
4. **Collaboration**: Modular files simplify collaborative work, as team members can work on different files or components without conflicts.

---

## File Analysis

### `provider.tf` 🌐

**AWS Provider Configuration**

```hcl
provider "aws" {
  region = var.aws_region
}
```

**Explanation:**
- **`provider "aws"`**: Configures the AWS provider for interacting with AWS services.
- **`region`**: Defines the AWS region for resource creation, using a variable for flexibility.

**Key Point 🔑:** `provider.tf` specifies the AWS provider and region, setting the foundation for the infrastructure setup.

**Best Practice 🏆:** Use variables for provider settings to ensure flexibility and maintainability across different environments.

---

### `vpc.tf` 🏗️

**VPC Creation**

```hcl
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "My VPC"
  }
}
```

**Explanation:**
- **`aws_vpc`**: Creates a VPC with a defined CIDR block.
- **`cidr_block`**: Specifies the IP range for the VPC, using a variable for adaptability.

**Key Point 🔑:** `vpc.tf` defines the core network boundary within which other resources will be provisioned.

**Best Practice 🏆:** Use variables for CIDR blocks to allow for easy adjustments and ensure consistency across environments.

---

### `publicSubnet.tf` 🌐

**Public Subnet Creation**

```hcl
resource "aws_subnet" "public_subnet" {
  vpc_id             = aws_vpc.vpc.id
  cidr_block         = var.public_subnet_cidr
  availability_zone  = var.public_subnet_az
  tags = {
    Name = "Public Subnet"
  }
}
```

**Explanation:**
- **`aws_subnet`**: Creates a public subnet within the VPC.
- **`cidr_block`**: Defines the IP range for the public subnet.
- **`availability_zone`**: Specifies the AWS AZ for the subnet.

**Key Point 🔑:** `publicSubnet.tf` provisions a subnet that allows direct access to the internet, ideal for public-facing resources.

**Best Practice 🏆:** Ensure subnets are spread across multiple availability zones to enhance resilience and high availability.

---

### `privateSubnet.tf` 🌐

**Private Subnet Creation**

```hcl
resource "aws_subnet" "private_subnet" {
  vpc_id             = aws_vpc.vpc.id
  cidr_block         = var.private_subnet_cidr
  availability_zone  = var.private_subnet_az
  tags = {
    Name = "Private Subnet"
  }
}
```

**Explanation:**
- **`aws_subnet`**: Creates a private subnet within the VPC.
- **`cidr_block`**: Defines the IP range for the private subnet.
- **`availability_zone`**: Specifies the AWS AZ for the subnet.

**Key Point 🔑:** `privateSubnet.tf` sets up a subnet that does not have direct internet access, suitable for internal resources.

**Best Practice 🏆:** Separate public and private subnets to control access and improve security.

---

### `igw.tf` 🌐

**Internet Gateway Creation**

```hcl
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "my IGW"
  }
}
```

**Explanation:**
- **`aws_internet_gateway`**: Creates an Internet Gateway to enable internet access for the VPC.
- **`vpc_id`**: Associates the gateway with the VPC.

**Key Point 🔑:** `igw.tf` provisions an Internet Gateway, which is essential for enabling internet access for resources in the public subnet.

**Best Practice 🏆:** Ensure the Internet Gateway is properly tagged and associated with the correct VPC.

---

### `elasticIP.tf` 🌐

**Elastic IP Allocation**

```hcl
resource "aws_eip" "elastic_ip" {
  domain = "vpc"
  tags = {
    Name = "Elastic IP 1"
  }
}
```

**Explanation:**
- **`aws_eip`**: Allocates an Elastic IP address for use with a NAT Gateway.
- **`domain`**: Specifies that the IP is for VPC usage.

**Key Point 🔑:** `elasticIP.tf` allocates a static IP address necessary for the NAT Gateway to allow private subnet instances to access the internet.

**Best Practice 🏆:** Use Elastic IPs for NAT Gateways to maintain consistent IP addresses.

---

### `natgw.tf` 🌐

**NAT Gateway Creation**

```hcl
resource "aws_nat_gateway" "public_nat" {
  subnet_id     = aws_subnet.public_subnet.id
  allocation_id = aws_eip.elastic_ip.id
  tags = {
    Name = "NAT Gateway"
  }

  depends_on = [aws_internet_gateway.igw]
}
```

**Explanation:**
- **`aws_nat_gateway`**: Creates a NAT Gateway in the public subnet.
- **`subnet_id`**: Specifies the subnet for the NAT Gateway.
- **`allocation_id`**: Associates the NAT Gateway with an Elastic IP.

**Key Point 🔑:** `natgw.tf` enables instances in private subnets to access the internet while keeping them inaccessible from external sources.

**Best Practice 🏆:** Place the NAT Gateway in a public subnet and ensure it has a valid Elastic IP.

---

### `rt.tf` 🌐

**Route Tables and Associations**

```hcl
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

resource "aws_route_table_association" "public_subnet_route" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "private_subnet_route" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route.id
}
```

**Explanation:**
- **`aws_route_table`**: Creates route tables for public and private subnets.
- **`aws_route_table_association`**: Associates each route table with the corresponding subnet.

**Key Point 🔑:** `rt.tf` manages routing for both public and private subnets, ensuring proper traffic flow within the VPC.

**Best Practice 🏆:** Use separate route tables for public and private subnets to control routing behavior effectively.

---

### `key.tf` 🔐

**Key Pair and Private Key Creation**

```hcl
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.my_key.public_key_openssh

  tags = {
    Name = "Generated Key"
  }
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.my_key.private_key_pem
  filename = var.private_key_path
  depends_on = [aws_key_pair.generated_key]
}
```

**Explanation:**
- **`tls_private_key`**: Generates a new RSA private key.
- **`aws_key_pair`**: Creates a key pair in AWS using the generated public key.
- **`local_file`**: Stores the private key locally.

**Key Point 🔑:** `key.tf` creates and manages a key pair for SSH access to instances and stores the private key securely.

**Best Practice 🏆:** Use strong key algorithms and ensure private keys are stored securely and not exposed.

---

### `ec2Instance.tf` 🌐

**EC2 Instance Creation**

```hcl
resource "aws_instance" "web

server" {
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

**Explanation:**
- **`aws_instance`**: Launches an EC2 instance in the public subnet.
- **`ami`**: Specifies the AMI ID for the instance.
- **`key_name`**: Uses the generated key pair for SSH access.

**Key Point 🔑:** `ec2Instance.tf` provisions an EC2 instance in the public subnet with SSH access and a specific AMI.

**Best Practice 🏆:** Configure root block devices with appropriate volume types and sizes based on instance needs.

---

### `sg.tf` 🔒

**Security Group Creation**

```hcl
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
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SSH, HTTP & ICMP"
  }
}
```

**Explanation:**
- **`aws_security_group`**: Creates a security group to control access to the EC2 instance.
- **`ingress`**: Defines allowed inbound traffic (SSH, HTTP, ICMP).
- **`egress`**: Defines outbound traffic rules.

**Key Point 🔑:** `sg.tf` configures security group rules to manage access to the EC2 instance.

**Best Practice 🏆:** Follow the principle of least privilege by restricting security group rules to only the necessary ports and IP ranges.

---

### `variable.tf` 📋

**Variable Definitions**

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

**Explanation:**
- **`variable.tf`**: Defines variables used across the Terraform configuration, including region, CIDR blocks, AMI ID, and more.

**Key Point 🔑:** `variable.tf` specifies the configuration options and defaults, providing a flexible and reusable setup.

**Best Practice 🏆:** Clearly document variable descriptions to ensure clarity for users and maintain consistency across Terraform configurations.

---

### `terraform.tfvars` 📂

**Variable Values**

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

**Explanation:**
- **`terraform.tfvars`**: Contains values for the variables defined in `variable.tf`, providing actual data used during deployment.

**Key Point 🔑:** `terraform.tfvars` is where you specify the values for the variables, customizing the Terraform setup for your environment.

**Best Practice 🏆:** Store sensitive values and configurations in `terraform.tfvars` to separate them from the main codebase, ensuring better security and organization.

---