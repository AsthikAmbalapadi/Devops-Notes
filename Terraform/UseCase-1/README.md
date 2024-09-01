### Introduction 🌟

This Terraform configuration establishes a foundational AWS infrastructure, including a Virtual Private Cloud (VPC), subnets, internet connectivity, and an EC2 instance. The following sections detail each component, highlighting their functions, best practices, and key points to ensure an optimal and secure setup.

---

### 1. **AWS Provider Configuration** 🌐

```hcl
provider "aws" {
  region = "us-east-1"
}
```
- **`provider "aws"`**: Configures the AWS provider for resource management.
- **`region`**: Specifies the AWS region where resources will be deployed.
- **Key Point** 🔑: Selecting the appropriate region can impact latency and cost. Choose a region geographically closest to your users for better performance.

**Best Practice** 🏆: Ensure the selected region supports all AWS services required for your infrastructure and complies with data residency regulations.

---

### 2. **Virtual Private Cloud (VPC)** 🏠

```hcl
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "My VPC"
  }
}
```
- **`resource "aws_vpc" "vpc"`**: Creates a VPC with a specific CIDR block.
- **`cidr_block`**: Defines the IP address range for the VPC.
- **`tags`**: Provides metadata for easier identification.
- **Key Point** 🔑: A VPC isolates network resources within AWS, allowing secure and organized networking.

**Best Practice** 🏆: Choose a CIDR block that provides sufficient IP addresses for current and future needs. Avoid overlapping CIDR blocks with other networks to prevent routing issues.

---

### 3. **Public Subnet** 🌍

```hcl
resource "aws_subnet" "public_subnet" {
  vpc_id             = aws_vpc.vpc.id
  cidr_block         = "10.0.1.0/24"
  availability_zone  = "us-east-1a"
  tags = {
    Name = "Public Subnet"
  }
}
```
- **`resource "aws_subnet" "public_subnet"`**: Defines a public subnet within the VPC.
- **`vpc_id`**: Associates the subnet with the specified VPC.
- **`cidr_block`**: Specifies the IP range for the subnet.
- **`availability_zone`**: Determines the availability zone where the subnet resides.
- **`tags`**: Helps identify the subnet.
- **Key Point** 🔑: Public subnets allow resources to be accessible from the internet via an Internet Gateway.

**Best Practice** 🏆: Distribute subnets across multiple availability zones for high availability. Ensure the CIDR block does not overlap with other subnets in the VPC.

---

### 4. **Private Subnet** 🔒

```hcl
resource "aws_subnet" "private_subnet" {
  vpc_id             = aws_vpc.vpc.id
  cidr_block         = "10.0.2.0/24"
  availability_zone  = "us-east-1b"
  tags = {
    Name = "Private Subnet"
  }
}
```
- **`resource "aws_subnet" "private_subnet"`**: Creates a private subnet within the VPC.
- **`vpc_id`**: Links the subnet to the VPC.
- **`cidr_block`**: Defines the IP range for the private subnet.
- **`availability_zone`**: Specifies the availability zone for the subnet.
- **`tags`**: Adds metadata to identify the subnet.
- **Key Point** 🔑: Private subnets are used for resources that should not be directly accessible from the internet.

**Best Practice** 🏆: Ensure private subnets have access to the internet through a NAT Gateway if necessary. Maintain separate CIDR blocks to avoid overlap.

---

### 5. **Internet Gateway** 🌐

```hcl
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "my IGW"
  }
}
```
- **`resource "aws_internet_gateway" "igw"`**: Creates an Internet Gateway for the VPC.
- **`vpc_id`**: Attaches the Internet Gateway to the VPC.
- **`tags`**: Tags the Internet Gateway for identification.
- **Key Point** 🔑: An Internet Gateway allows communication between instances in the VPC and the internet.

**Best Practice** 🏆: Ensure that only public subnets are associated with the Internet Gateway to secure private resources.

---

### 6. **Elastic IP for NAT Gateway** 🆓

```hcl
resource "aws_eip" "elastic_ip" {
  domain = "vpc"
  tags = {
    Name = "Elastic IP 1"
  }
}
```
- **`resource "aws_eip" "elastic_ip"`**: Allocates an Elastic IP address for use with a NAT Gateway.
- **`domain`**: Specifies that the IP is for use within a VPC.
- **`tags`**: Tags the Elastic IP for identification.
- **Key Point** 🔑: Elastic IPs are static IP addresses that persist across instance stops and starts.

**Best Practice** 🏆: Use Elastic IPs judiciously as they are a limited resource. Avoid unnecessary allocation to manage costs effectively.

---

### 7. **NAT Gateway** 🌐

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
- **`resource "aws_nat_gateway" "public_nat"`**: Creates a NAT Gateway in the public subnet.
- **`subnet_id`**: Places the NAT Gateway in the specified subnet.
- **`allocation_id`**: Associates the NAT Gateway with the Elastic IP.
- **`tags`**: Tags the NAT Gateway for easy identification.
- **`depends_on`**: Ensures the Internet Gateway is created before the NAT Gateway.
- **Key Point** 🔑: NAT Gateways allow instances in private subnets to access the internet without exposing them to inbound traffic.

**Best Practice** 🏆: Use NAT Gateways in a highly available configuration by deploying them in multiple availability zones. Monitor their usage to optimize costs.

---

### 8. **Public Route Table** 🛤️

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
```
- **`resource "aws_route_table" "public_route"`**: Creates a route table for public subnets.
- **`vpc_id`**: Associates the route table with the VPC.
- **`route`**: Defines routing rules.
  - **`cidr_block`**: Specifies the IP range for the route.
  - **`gateway_id`**: Defines the target for the route.
- **`tags`**: Tags the route table for easy identification.
- **Key Point** 🔑: Route tables direct network traffic within the VPC. Public route tables should route traffic to the Internet Gateway.

**Best Practice** 🏆: Regularly review route tables to ensure they meet your current network design and security requirements. Use network ACLs for additional security layers.

---

### 9. **Private Route Table** 🛤️

```hcl
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
```
- **`resource "aws_route_table" "private_route"`**: Creates a route table for private subnets.
- **`vpc_id`**: Associates the route table with the VPC.
- **`route`**: Specifies routing rules.
  - **`cidr_block`**: IP range for the route.
  - **`gateway_id`**: Defines the target for the route (NAT Gateway for private subnets).
- **`tags`**: Tags the route table for easy identification.
- **Key Point** 🔑: Private route tables should route internet-bound traffic to a NAT Gateway to allow private instances to access the internet.

**Best Practice** 🏆: Ensure private route tables do not inadvertently allow public access. Regularly audit and update routing rules as needed.

---

### 10. **Security Group for SSH, HTTP, and ICMP** 🔐

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
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
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
- **`resource "aws_security_group" "allow_ssh_http_icmp"`**: Defines a security group to control inbound and outbound traffic.
- **`ingress`**: Rules for incoming traffic.
  - **`description`**: Describes the rule.
  - **`from_port`** and **`to_port`**: Specifies the port range.
  - **`protocol`**: Defines the protocol.
  - **`cidr_blocks`**: IP ranges allowed for inbound traffic.
- **`egress`**: Rules for outgoing traffic.
  - **`description`**: Describes the rule.
  - **`from_port`** and **`to_port`**: Specifies the port range.
  - **`protocol`**: Defines the protocol.
  - **`cidr_blocks`**: IP ranges allowed for outbound traffic.
- **Key Point** 🔑: Security groups act as virtual firewalls for your instances. They control inbound and outbound traffic to enhance security.

**Best Practice** 🏆: Restrict inbound traffic to only necessary ports and IP addresses. Regularly review and update security group rules to adhere to the principle of least privilege.

---

### 11. **Generate and Use Key Pair** 🔑

```hcl
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "key"
  public_key = tls_private_key.my_key.public_key_openssh

  tags = {
    Name = "Generated Key"
  }
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.my_key.private_key_pem
  filename = "C:/Users/Asthik Creak/Desktop/Testing/Terraform/project_1/key_local.pem"
  depends_on = [aws_key_pair.generated_key]
}
```
- **`resource "tls_private_key" "my_key"`**: Generates a new RSA private key.
- **`resource "aws_key_pair" "generated_key"`**: Creates an AWS key pair using the generated public key.
- **`resource "local_file" "private_key_pem"`**: Saves the private key to a local file.
- **Key Point** 🔑: Key pairs are used for securely accessing EC2 instances via SSH. The private key should be kept secure.

**Best Practice** 🏆: Use strong encryption (e.g., RSA with 4096 bits) for key pairs. Store private keys securely and avoid hardcoding sensitive information directly into configurations.

---

### 12. **EC2 Instance Setup** 🖥️

```hcl
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
```
- **`resource "aws_instance" "webserver"`**: Launches an EC2 instance with specified configurations.
- **`ami`**: Specifies the Amazon Machine Image (AMI) to use.
- **`instance_type`**: Defines the instance type.
- **`key_name`**: Associates the key pair for SSH access.
- **`subnet_id`**: Places the instance in the specified subnet.
- **`security_groups`**: Applies security group rules.
- **`associate_public_ip_address`**: Assigns a public IP to the instance.
- **`user_data`**: Runs a script on instance startup.
- **`root_block_device`**: Configures the root volume of the instance.
- **`tags`**: Tags the instance for easy identification.
- **Key Point** 🔑: EC2 instances are the core compute resources. Proper configuration ensures secure access and appropriate resource allocation.

**Best Practice** 🏆: Use the latest AMIs for security updates. Monitor instance performance and adjust instance types as needed. Ensure user data scripts are idempotent and tested.

---

### 13. **Alternative Security Group Configuration** 🔐

```hcl
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
  ip_protocol       = "-1"
}
```
- **`resource "aws_security_group" "allow_ssh_tcp"`**: Defines a security group allowing SSH and TCP traffic.
- **`resource "aws_vpc_security_group_ingress_rule"`**: Adds rules to allow specific inbound traffic.
- **`resource "aws_vpc_security_group_egress_rule"`**: Configures outbound traffic rules.
- **Key Point** 🔑: This configuration offers a more granular approach to managing security group rules.

**Best Practice** 🏆: Use the most restrictive rules necessary for your application. Regularly review security group configurations to ensure they align with current security policies.

---

### 14. **Output Private Key** 🔑

```hcl
output "private_key_pem" {
  value     = tls_private_key.my_key.private_key_pem
  sensitive = true
}
```
- **`output "private_key_pem"`**: Outputs the private key.
- **`value`**: Displays the private key value.
- **`sensitive`**: Marks the output as sensitive to prevent accidental exposure.
- **Key Point** 🔑: Sensitive outputs should be handled carefully to avoid security risks.

**Best Practice** 🏆: Avoid outputting sensitive information such as private keys. Instead, use secure methods for key management and distribution.

---

### Summary 📚

This Terraform configuration provides a comprehensive setup for a basic AWS environment, including VPC creation, subnet setup, internet and NAT gateways, security groups, and an EC2 instance. By following best practices and understanding each component's role, you can build a robust, scalable, and secure infrastructure on AWS. Regularly review and update configurations to adapt to evolving needs and security requirements.

---