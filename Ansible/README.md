## **Introduction to Ansible for DevOps**

Ansible is an open-source automation tool that has transformed how DevOps teams manage infrastructure, deploy applications, and automate IT tasks. It provides a straightforward yet powerful framework for automating complex operations, from server configuration to application deployment. Ansible's simplicity and flexibility make it a key tool in the DevOps ecosystem.

### **Key Features of Ansible**

1. **Agentless Architecture**: Ansible operates over SSH and doesn’t require any agents on managed nodes, which simplifies setup and reduces security risks compared to agent-based systems like Chef or Puppet.
  
2. **YAML-Based Playbooks**: Ansible uses YAML (YAML Ain't Markup Language) to define its playbooks, making them human-readable and easy to understand. This declarative language allows users to describe automation tasks in a clear and concise manner.
  
3. **Idempotency**: Ansible ensures that tasks are idempotent, meaning they can be run multiple times without altering the system if it's already in the desired state. This prevents unintended changes and ensures consistency.

4. **Extensive Module Library**: Ansible includes a vast collection of built-in modules for a wide range of tasks, such as managing packages, services, and cloud resources. Users can also extend Ansible with custom modules.

5. **Dynamic Inventory**: Ansible supports both static and dynamic inventories. Dynamic inventory scripts allow Ansible to pull host information from external sources like cloud providers or CMDB systems, making it adaptable to dynamic environments.

### **Ansible Architecture and Components**

#### **1. Control Node**
The Control Node is the machine where Ansible is installed and from which all automation tasks are initiated. It executes playbooks, runs ad-hoc commands, and manages inventory files.

- **Setup**: The Control Node typically runs on a Linux-based system, which could be a local machine or a cloud instance. Ansible is installed on this machine, and it manages other nodes remotely using SSH.
  
- **Security**: Given that the Control Node has access to all managed nodes, securing it is crucial. This includes using strong SSH keys, limiting SSH access, and monitoring login attempts.

#### **2. Managed Nodes**
Managed Nodes are the target servers, virtual machines, containers, or devices that the Control Node manages. These nodes receive instructions from the Control Node to perform tasks defined in playbooks or ad-hoc commands.

- **SSH Access**: Managed Nodes must be accessible via SSH from the Control Node, which typically requires setting up SSH keys to enable password-less login.
  
- **Operating Systems**: Ansible can manage a variety of operating systems, including various Linux distributions, Windows, and network devices that support SSH.

#### **3. Inventory**
The Inventory is a crucial component in Ansible that lists the Managed Nodes and their groupings. It can be defined in a static file or generated dynamically.

- **Default Inventory File**: Located at `/etc/ansible/hosts` by default, although a different inventory file can be specified using the `-i` option.
  
- **Groups and Variables**: Nodes can be grouped in the inventory, allowing specific configurations or tasks to be applied to subsets of nodes. Variables can also be defined to customize behavior across different environments.

Example Inventory File:
```ini
[webservers]
webserver1 ansible_host=192.168.1.10
webserver2 ansible_host=192.168.1.11

[dbservers]
dbserver1 ansible_host=192.168.1.20
dbserver2 ansible_host=192.168.1.21

[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

#### **4. Modules**
Modules are the building blocks of Ansible, performing specific tasks like installing packages, managing services, or configuring files on Managed Nodes.

- **Common Modules**:
  - **`yum`**: Manages packages on RPM-based distributions like CentOS and RHEL.
  - **`apt`**: Manages packages on Debian-based distributions like Ubuntu.
  - **`service`**: Manages services on the Managed Nodes.
  - **`copy`**: Copies files from the Control Node to the Managed Nodes.
  - **`template`**: Copies and processes Jinja2 templates on the Managed Nodes.

Example of Module Usage in a Playbook:
```yaml
- name: Install HTTPD
  yum:
    name: httpd
    state: present
```

#### **5. Playbooks**
Playbooks are the core of Ansible's automation capabilities, defined in YAML files that specify tasks to be executed on Managed Nodes.

- **Structure of a Playbook**:
  - **Plays**: Define the hosts on which the tasks will be executed.
  - **Tasks**: Individual operations performed on the Managed Nodes, such as installing a package or starting a service.
  - **Handlers**: Tasks that run only when triggered by other tasks, typically used to restart services or perform cleanup operations.
  - **Variables**: Customize playbooks for different environments or use cases.

Example of a Simple Playbook:
```yaml
- hosts: webservers
  tasks:
    - name: Install Apache
      yum:
        name: httpd
        state: present

    - name: Start Apache
      service:
        name: httpd
        state: started
```

#### **6. Roles**
Roles provide a structured way to organize and reuse Ansible code, bundling tasks, variables, files, and templates into a standardized format.

- **Role Directory Structure**:
  - **`tasks/`**: Contains the main list of tasks for the role.
  - **`handlers/`**: Contains handlers triggered by tasks.
  - **`files/`**: Stores files that are copied to Managed Nodes.
  - **`templates/`**: Contains Jinja2 templates for dynamic configuration files.
  - **`vars/`**: Holds variables specific to the role.
  - **`defaults/`**: Default variables for the role.
  - **`meta/`**: Metadata about the role, such as dependencies.

Example Role Structure:
```
my_role/
├── tasks/
│   └── main.yml
├── handlers/
│   └── main.yml
├── files/
│   └── httpd.conf
├── templates/
│   └── httpd.conf.j2
├── vars/
│   └── main.yml
├── defaults/
│   └── main.yml
└── meta/
    └── main.yml
```

### **Integration of Ansible with DevOps Tools**

Ansible integrates seamlessly with other DevOps tools to enhance automation and streamline the CI/CD pipeline.

- **Jenkins**: Jenkins can trigger Ansible playbooks for server configuration, application deployment, and post-deployment tasks.
  
- **Terraform**: While Terraform is used for infrastructure provisioning, Ansible takes over configuration management, ensuring the servers are properly set up after being created.
  
- **Docker**: Ansible can manage Docker containers, networks, and services, handling tasks such as deploying containers and orchestrating multi-container setups.
  
- **Kubernetes**: Ansible can manage Kubernetes clusters, deploy applications to Kubernetes, and automate various cluster operations.

### **Advantages and Disadvantages of Ansible**

#### **Advantages**:
- **Ease of Use**: Ansible’s simple, human-readable syntax is accessible to both developers and system administrators.
- **Agentless**: No need to install agents on Managed Nodes, reducing overhead and simplifying management.
- **Idempotency**: Ensures that running the same playbook multiple times doesn’t change the system if it’s already in the desired state.
- **Flexibility**: Capable of automating a wide range of tasks, from simple configuration management to complex orchestration.
- **Extensibility**: Supports custom modules and plugins, facilitating integration with other tools and systems.

#### **Disadvantages**:
- **Performance**: Ansible can be slower than agent-based systems, especially when managing a large number of nodes, due to its SSH-based communication.
- **Limited Windows Support**: While Ansible can manage Windows systems, its capabilities are more mature on Linux.
- **Complexity in Large Environments**: Managing many playbooks and roles can become complex, requiring careful organization.

### **Best Practices for Using Ansible**

- **Organize Your Inventory**: Use groups and variables in the inventory file to keep things organized and manageable.
  
- **Use Roles for Reusability**: Encapsulate related tasks into roles to promote reuse and maintainability.
  
- **Keep Playbooks Simple**: Write modular, focused playbooks that do one thing well. Avoid creating large, monolithic playbooks.
  
- **Use Version Control**: Store playbooks, roles, and inventory in a version control system like Git to track changes and collaborate with others.
  
- **Test Playbooks**: Always test playbooks in a staging environment before applying them to production systems. Consider using tools like Molecule for testing roles.
  
- **Secure SSH Keys**: Ensure that SSH keys used by Ansible are secure and have the necessary permissions.

---

### **Understanding Ansible Ad-Hoc Commands and Gathering Facts**

#### **Understanding Ansible Ad-Hoc Commands**

**Ad-Hoc Commands**:
- Ansible ad-hoc commands are used for executing quick, one-off tasks. They are ideal for simple operations or when you need to test and validate your setup without creating a full playbook.

**Syntax**:
- The basic syntax of an ad-hoc command is:
  ```bash
  ansible <group> -m <module> -a "<module-arguments>"
  ```

  - `<group>`: Specifies the group of hosts defined in your inventory file.
  - `-m <module>`: Indicates the Ansible module to use (e.g., `yum`, `file`, `git`).
  - `-a "<module-arguments>"`: Provides arguments to the module, such as package names or file paths.

#### **Gathering Facts**

**Fact Gathering**:
- Fact gathering is a process where Ansible collects detailed information about target systems. This information is automatically gathered before playbook execution and stored in variables.

**Purpose**:
- Provides insight into system configurations and statuses, such as OS version, network interfaces, memory, and disk space.

**Command**:
- To retrieve and display all gathered facts for all hosts, use the `setup` module:
  ```bash
  ansible all -m setup
  ```
  - **Explanation**:
    - `-m setup`: Uses the `setup` module to gather system facts.
    - `all`: Targets all hosts in the inventory.

**Output**:
- The command displays various details about each system, including hardware, software, and network configuration.

## **Scenario 1: Configuring AWS Instances and Ansible Setup**

### **1. Creating AWS Instances**

1. **Log in to AWS Management Console**:
   - Open your web browser and navigate to the [AWS Management Console](https://aws.amazon.com/console/).
   - Enter your credentials (email and password) to access the console.

2. **Navigate to EC2 Dashboard**:
   - From the AWS Management Console, go to the "Services" menu at the top and select "EC2" under the "Compute" category.
   - This will take you to the EC2 Dashboard, where you can manage your virtual machines (instances).

3. **Launch Instances**:
   - Click on the "Launch Instance" button to start the process of creating a new virtual machine.
   - **AMI (Amazon Machine Image)**: Choose **Amazon Linux 2 AMI (HVM)**, which is a popular, stable Linux distribution optimized for the AWS environment.
   - **Instance Type**: Select `t2.micro`, which is part of the free tier and provides enough resources for basic tasks.
   - **Key Pair**: If you already have a key pair, select it from the list. If not, create a new one by clicking on "Create a new key pair," naming it, and downloading the `.pem` file, which you will need for SSH access.
   - **Security Groups**: Create or select a security group that allows the necessary inbound traffic. Ensure that you allow:
     - **SSH (port 22)**: For remote access to your instances.
     - **HTTP/HTTPS (ports 80/443)**: If your instances will serve web traffic.
   - **Storage**: The default 8 GB of General Purpose SSD (gp2) storage is usually sufficient, but you can adjust it based on your needs.
   - **Tags**: Optionally, add tags to your instances for easier identification, such as Name: Ansible-Control-Node or Name: Webserver-1.

4. **Launch the Instances**:
   - Review your settings and click on "Launch Instance" to create your instance.
   - Repeat the above steps to create a total of **5 instances**:
     - **1 instance for the Ansible Control Node**.
     - **4 instances for the Managed Nodes (e.g., Webserver-1, Webserver-2, Appserver-1, Appserver-2)**.
   - After the instances are launched, note down their public IP addresses. These IPs will be used to connect to the instances and configure them with Ansible.

### **2. Installing Ansible on the Control Node**

1. **SSH into the Ansible Control Node**:
   - Open your terminal or command prompt.
   - Use the `ssh` command to connect to the Ansible Control Node using the key pair you downloaded:

   ```bash
   ssh -i /path/to/your-key.pem ec2-user@<Ansible-Control-Node-Public-IP>
   ```

   - Replace `/path/to/your-key.pem` with the actual path to your `.pem` file and `<Ansible-Control-Node-Public-IP>` with the public IP address of your control node.

2. **Install Ansible**:
   - Once logged in, update the system's package list to ensure you have the latest software:

   ```bash
   sudo yum update -y
   ```

   - Install Ansible using the Amazon Linux Extras repository:

   ```bash
   sudo amazon-linux-extras install ansible2 -y
   ```

   - This command installs the Ansible package, along with all necessary dependencies.

3. **Verify Ansible Installation**:
   - Confirm that Ansible has been installed correctly by checking its version:

   ```bash
   ansible --version
   ```

   - You should see output that includes the version number, configuration file location, and details about Python and other dependencies.

### **3. Configuring the `/etc/ansible/` Directory**

- **`ansible.cfg`**:
  - The `ansible.cfg` file contains various configuration settings for Ansible. It can be customized to suit your environment, but the default settings are usually sufficient for basic tasks.
  - Some key settings you might consider:
    - **inventory**: Specifies the location of the inventory file. By default, it's set to `/etc/ansible/hosts`.
    - **remote_user**: Defines the default SSH user to connect to managed nodes. It can be overridden on a per-task basis.
    - **timeout**: Sets the SSH connection timeout, which can be adjusted based on network conditions.

- **`hosts`**:
  - The `hosts` file is the default inventory file used by Ansible to define which machines it should manage. It contains groups of hosts (e.g., webservers, databases) and can include variables that apply to all hosts in a group.
  - This file can be edited to include the IP addresses or hostnames of your managed nodes, as well as any necessary variables.

- **`roles/`**:
  - The `roles/` directory is where reusable Ansible roles are stored. Roles are a way to package and organize tasks, variables, files, templates, and handlers into a structured format.
  - When developing complex playbooks, roles help keep your playbook files clean and organized.

### **4. Setting Up the Inventory File**

1. **Edit the Default Inventory File**:
   - Open the inventory file (`/etc/ansible/hosts`) using a text editor like `vim`:

   ```bash
   sudo vim /etc/ansible/hosts
   ```

   - This file will define the managed nodes (i.e., the AWS instances) that Ansible will control.

2. **Define Managed Nodes**:
   - Add your AWS instances to the inventory file, grouping them as appropriate:

   ```ini
   [webserver]
   webserver1 ansible_host=<Webserver-1-Public-IP>
   webserver2 ansible_host=<Webserver-2-Public-IP>

   [appserver]
   appserver1 ansible_host=<Appserver-1-Public-IP>
   appserver2 ansible_host=<Appserver-2-Public-IP>

   [all:vars]
   ansible_user=ec2-user
   ansible_ssh_private_key_file=/path/to/your-key.pem
   ```

   - **`[webserver]`**: Group for web server instances. Replace `<Webserver-1-Public-IP>` and `<Webserver-2-Public-IP>` with the actual public IP addresses.
   - **`[appserver]`**: Group for application server instances. Replace `<Appserver-1-Public-IP>` and `<Appserver-2-Public-IP>` with the actual public IP addresses.
   - **`[all:vars]`**: Global variables that apply to all hosts. `ansible_user` specifies the SSH user (e.g., `ec2-user`), and `ansible_ssh_private_key_file` provides the path to the SSH private key.

### **5. Verifying SSH Connections**

1. **Test SSH Connection**:
   - Before using Ansible to manage the nodes, test the SSH connection manually to ensure that you can access each managed node:

   ```bash
   ssh -i /path/to/your-key.pem ec2-user@<Managed-Node-Public-IP>
   ```

   - Replace `/path/to/your-key.pem` with the path to your key file and `<Managed-Node-Public-IP>` with the IP address of a managed node.

2. **Set Up SSH Key Authentication for Ansible User**:
   - For passwordless SSH access, you can set up SSH key authentication for the `ansible` user. This step is crucial for Ansible to work without needing to manually enter passwords.

   - **Generate SSH Key Pair**:
     - On the Ansible Control Node, generate a new SSH key pair:

     ```bash
     ssh-keygen -t rsa
     ```

     - Follow the prompts to save the key pair (default location is `~/.ssh/id_rsa`).

   - **Copy Public Key to Managed Nodes**:
     - Use the `ssh-copy-id` command to copy your public key to each managed node:

     ```bash
     ssh-copy-id -i ~/.ssh/id_rsa.pub ec2-user@<Managed-Node-Public-IP>
     ```

     - This command installs the public key to the managed node, allowing passwordless SSH access.

3. **Verify SSH Connection for Ansible User**:
   - After setting up SSH key authentication, verify that you can connect to the managed node using the `ansible` user:

   ```bash
   ssh ansible@<Managed-Node-Public-IP>
   ```

   - You should be able to log in without entering a password.

4. **Test Connection with Ansible**:
   - Finally, test the connection from Ansible to ensure everything is set up correctly:

   ```bash
   ansible all -m ping -u ansible
   ```

   - This command pings all hosts in the inventory using the `ansible` user. If everything is configured correctly, you should see a "pong" response from each host.

### **6. Managing Ansible User Permissions**

1. **Verify Sudo Privileges**:
   - Check if the `ansible` user has sudo privileges by running a command that requires elevated permissions:

   ```bash
   ansible all -m shell -a "sudo whoami" -u ansible
   ```

   - The output should return "root," indicating that the `ansible` user can execute commands with sudo privileges.

2. **Test Ad-Hoc Command Execution**:
   - Use an ad-hoc command to verify that Ansible can execute tasks on the managed nodes:

   ```bash
   ansible all -m command -a "uptime" -u ansible
   ```

   - This command returns the uptime of each managed node, confirming that Ansible can run commands on the hosts.

---

## **Scenario 2: Deploying application using Ad-Hoc Commands**

### **Scenario Parameters**:
- For group `webserver`,
	- Go to the location /var/www/html, git clone the repository, https://github.com/AsthikDev/finexo-web-app.git
	- Install httpd from ansible control node to webserver target node & start httpd service & verify it.
	- Change the HTTPD conf file to listen to port 80 & restart the httpd service.
	- Verify the webserver is accessible from port 80.

- For group `appserver`,
	- Create directory /var/www/app & give required read, write & execute permissions.
	- Go to the location /var/www/app, git clone the repository, https://github.com/AsthikDev/mediplus-web-app.git
	- Install httpd from ansible control node to appserver target node & start httpd service & verify it.
	- Change the HTTPD conf file to listen to port 443, change the root location to /var/www/app & the index file to app.html & restart the httpd service.
	- Verify the appserver is accessible from port 443.

### **1. Executing Ansible Ad-Hoc Commands on webserver & appserver group**

#### **For Webserver Group**

1. **Install Git**:

   ```bash
   ansible webserver -b -m yum -a "name=git state=present"
   ```
   - **Explanation**:
     - `-b`: Enables privilege escalation to run commands as root.
     - `-m yum`: Uses the `yum` module to manage packages.
     - `-a "name=git state=present"`: Installs the `git` package if not already installed.

2. **Create /var/www/html Directory**:

   ```bash
   ansible webserver -b -m file -a "path=/var/www/html state=directory mode=0755"
   ```
   - **Explanation**:
     - `-m file`: Uses the `file` module to manage files and directories.
     - `-a "path=/var/www/html state=directory mode=0755"`: Creates the directory `/var/www/html` with permissions `0755`.

3. **Clone the Repository**:

   ```bash
   ansible webserver -b -m git -a "repo=https://github.com/AsthikDev/finexo-web-app.git dest=/var/www/html version=main"
   ```
   - **Explanation**:
     - `-m git`: Uses the `git` module to manage Git repositories.
     - `-a "repo=https://github.com/AsthikDev/finexo-web-app.git dest=/var/www/html version=main"`: Clones the repository to the specified destination.

4. **Install HTTPD**:

   ```bash
   ansible webserver -b -m yum -a "name=httpd state=present"
   ```
   - **Explanation**:
     - `-m yum`: Installs the `httpd` package.

5. **Start and Enable HTTPD Service**:

   ```bash
   ansible webserver -b -m systemd -a "name=httpd state=started enabled=yes"
   ```
   - **Explanation**:
     - `-m systemd`: Uses the `systemd` module to manage services.
     - `-a "name=httpd state=started enabled=yes"`: Starts and enables the `httpd` service to start on boot.

6. **Configure HTTPD to Listen on Port 80**:

   ```bash
   ansible webserver -b -m lineinfile -a "path=/etc/httpd/conf/httpd.conf regexp='^Listen ' line='Listen 80'"
   ```
   - **Explanation**:
     - `-m lineinfile`: Uses the `lineinfile` module to ensure a specific line is present in a file.
     - `-a "path=/etc/httpd/conf/httpd.conf regexp='^Listen ' line='Listen 80'"`: Configures HTTPD to listen on port 80.

7. **Restart HTTPD Service**:

   ```bash
   ansible webserver -b -m systemd -a "name=httpd state=restarted"
   ```
   - **Explanation**:
     - `-m systemd`: Uses the `systemd` module to restart the service.

#### **For Appserver Group**

1. **Install Git**:

   ```bash
   ansible appserver -b -m yum -a "name=git state=present"
   ```

2. **Create /var/www/app Directory**:

   ```bash
   ansible appserver -b -m file -a "path=/var/www/app state=directory mode=0755"
   ```

3. **Clone the Repository**:

   ```bash
   ansible appserver -b -m git -a "repo=https://github.com/AsthikDev/mediplus-web-app.git dest=/var/www/app version=main"
   ```

4. **Install HTTPD**:

   ```bash
   ansible appserver -b -m yum -a "name=httpd state=present"
   ```

5. **Configure HTTPD to Listen on Port 443**:

   ```bash
   ansible appserver -b -m lineinfile -a "path=/etc/httpd/conf/httpd.conf regexp='^Listen ' line='Listen 443'"
   ```

6. **Set DocumentRoot to /var/www/app**:

   ```bash
   ansible appserver -b -m lineinfile -a "path=/etc/httpd/conf/httpd.conf regexp='^DocumentRoot ' line='DocumentRoot \"/var/www/app\"'"
   ```

7. **Set DirectoryIndex to app.html**:

   ```bash
   ansible appserver -b -m lineinfile -a "path=/etc/httpd/conf/httpd.conf regexp='^DirectoryIndex ' line='DirectoryIndex app.html'"
   ```

8. **Start and Enable HTTPD Service**:

   ```bash
   ansible appserver -b -m systemd -a "name=httpd state=started enabled=yes"
   ```

9. **Restart HTTPD Service**:

   ```bash
   ansible appserver -b -m systemd -a "name=httpd state=restarted"
   ```

---

## **Scenario 3: Using Ansible Playbooks for Configuration Management**

### **1. Setting Up and Using Ansible Playbooks**

#### **Introduction to Ansible Playbooks**

Ansible playbooks are the core way to manage configurations and deployments across your infrastructure. They use YAML format to define the desired state of your systems and automate tasks in a systematic and repeatable manner. Playbooks consist of one or more plays, where each play maps a group of tasks to a set of hosts.

**Key Concepts**:
- **Playbook**: A YAML file with a list of plays.
- **Play**: A mapping of tasks to a group of hosts.
- **Tasks**: Actions that Ansible performs on the hosts.

### **2. Deploying a Web Application**

#### **Deploying a application to webserver group & appserver group using the same [scenario parameters](https://github.com/AsthikAmbalapadi/Devops-Notes/blob/main/Ansible/README.md#scenario-parameters)**

**Step 1**: **Create Directory for Playbooks**

1. **SSH into Your Ansible Control Node**:
   - Use SSH to connect to your Ansible control node:
     ```bash
     ssh -i /path/to/your-key.pem ec2-user@<Ansible-Control-Node-Public-IP>
     ```

2. **Navigate to the Home Directory**:
   - Change directory to the home directory where you will create a folder for your playbooks:
     ```bash
     cd ~
     ```

3. **Create a Directory for Playbooks**:
   - Create and navigate into a directory called `ansible_playbooks`:
     ```bash
     mkdir ansible_playbooks
     cd ansible_playbooks
     ```

**Step 2**: **Create and Configure Playbooks**

1. **Create `webserver_setup.yml`**

   - **Command**:
     ```bash
     nano ~/ansible_playbooks/webserver_setup.yml
     ```

   - **Content**:
     ```yaml
     ---
     - hosts: webserver
       become: yes
       tasks:
         - name: Install git
           yum:
             name: git
             state: present

         - name: Create /var/www/html directory
           file:
             path: /var/www/html
             state: directory
             mode: '0755'

         - name: Clone repository
           git:
             repo: 'https://github.com/AsthikDev/finexo-web-app.git'
             dest: /var/www/html
             version: main

         - name: Install httpd
           yum:
             name: httpd
             state: present

         - name: Configure httpd to listen on port 80
           lineinfile:
             path: /etc/httpd/conf/httpd.conf
             regexp: '^Listen '
             line: 'Listen 80'

         - name: Start and enable httpd service
           systemd:
             name: httpd
             state: started
             enabled: yes

         - name: Restart httpd service
           systemd:
             name: httpd
             state: restarted
     ```

   - **Explanation**:
     - **hosts**: Defines the target group of hosts. In this case, `webserver` refers to the group of servers designated for web server tasks in your inventory file.
     - **become: yes**: This tells Ansible to execute tasks with elevated privileges (sudo). It is often required for tasks that need administrative rights.
     - **yum**: This module manages packages on systems using the RPM package manager. Here, it ensures `git` and `httpd` (Apache) are installed.
     - **file**: Manages files and directories. `path` specifies the file or directory, `state` specifies the desired state (`directory` means create a directory), and `mode` sets permissions.
     - **git**: This module clones a Git repository. `repo` specifies the repository URL, `dest` is the destination directory, and `version` is the branch or commit to checkout.
     - **lineinfile**: This module ensures a specific line is present or absent in a file. It is used to configure Apache to listen on port 80.
     - **systemd**: Manages system services. `state: started` ensures the service is running, and `enabled: yes` ensures it starts on boot. `state: restarted` will restart the service to apply changes.

2. **Create `appserver_setup.yml`**

   - **Command**:
     ```bash
     nano ~/ansible_playbooks/appserver_setup.yml
     ```

   - **Content**:
     ```yaml
     ---
     - hosts: appserver
       become: yes
       tasks:
         - name: Install git
           yum:
             name: git
             state: present

         - name: Create /var/www/app directory
           file:
             path: /var/www/app
             state: directory
             mode: '0755'

         - name: Clone repository
           git:
             repo: 'https://github.com/AsthikDev/mediplus-web-app.git'
             dest: /var/www/app
             version: main

         - name: Install httpd
           yum:
             name: httpd
             state: present

         - name: Configure httpd to listen on port 443
           lineinfile:
             path: /etc/httpd/conf/httpd.conf
             regexp: '^Listen '
             line: 'Listen 443'

         - name: Set DocumentRoot to /var/www/app
           lineinfile:
             path: /etc/httpd/conf/httpd.conf
             regexp: '^DocumentRoot '
             line: 'DocumentRoot "/var/www/app"'

         - name: Set DirectoryIndex to app.html
           lineinfile:
             path: /etc/httpd/conf/httpd.conf
             regexp: '^DirectoryIndex '
             line: 'DirectoryIndex app.html'

         - name: Start and enable httpd service
           systemd:
             name: httpd
             state: started
             enabled: yes

         - name: Restart httpd service
           systemd:
             name: httpd
             state: restarted
     ```

   - **Explanation**:
     - Similar to the `webserver_setup.yml`, but targets `appserver` group with configurations specific to app servers.

**Step 3**: **Run the Playbooks**

1. **Execute `webserver_setup.yml`**:
   - Run the playbook to apply configurations to the `webserver` group:
     ```bash
     ansible-playbook ~/ansible_playbooks/webserver_setup.yml
     ```

2. **Execute `appserver_setup.yml`**:
   - Run the playbook to apply configurations to the `appserver` group:
     ```bash
     ansible-playbook ~/ansible_playbooks/appserver_setup.yml
     ```

   - **Explanation**:
     - This command will execute the playbook against the specified hosts in the inventory file. Ensure that the user running the playbook has necessary permissions on the target hosts.

---

## **Deeper Dive into Ansible Concepts and Modules**

### **1. Ansible Playbooks**

- **Structure**:
  - **Playbook Header**: Starts with `---` and includes a list of plays.
  - **Plays**: Define the tasks and are mapped to hosts.
  - **Tasks**: Actions executed by Ansible. Each task uses a module to perform an action.
  - **Handlers**: Special tasks that run when notified by other tasks. Useful for restarting services only when changes occur.

- **Best Practices**:
  - **Organize Playbooks**: Keep playbooks organized in directories based on roles or environments.
  - **Use Variables**: Define variables in separate files or within playbooks to manage different configurations.
  - **Test Playbooks**: Use tools like `molecule` to test playbooks in isolated environments.

### **2. Ansible Modules**

- **yum**: Manages packages on RPM-based distributions.
  - **Parameters**:
    - `name`: The name of the package.
    - `state`: Desired state (`present`, `absent`).

- **file**: Manages file and directory states.
  - **Parameters**:
    - `path`: Path to the file or directory.
    - `state`: Desired state (`directory`, `touch`, `absent`).
    - `mode`: Permissions for files/directories.

- **git**: Manages Git repositories.
  - **Parameters**:
    - `repo`: URL of the repository.
    - `dest`: Destination directory on the target machine.
    - `version`: Branch or tag to checkout.

- **lineinfile**: Ensures a line is present or absent in a file.
  - **Parameters**:
    - `path`: File path.
    - `regexp`: Regular expression to search for.
    - `line`: Line to add or replace.

- **systemd**: Manages systemd services.
  - **Parameters**:
    - `name`: Name of the service.
    - `state`: Desired state (`started`, `stopped`, `restarted`).
    - `enabled`: Whether the service should start on boot (`yes`, `no`).

- **service**: Manages services on older systems not using systemd.
  - **Parameters**:
    - `name`: Service name.
    - `state`: Desired state (`started`, `stopped`, `restarted`).

---

## Ansible Roles

### What is an Ansible Role?

An Ansible role is a modular way of organizing playbooks into reusable components. Roles help you define a set of tasks, variables, files, templates, and handlers in a structured way. Roles can be shared, reused, and maintained independently, which promotes clean and organized playbooks.

### Directory Structure of an Ansible Role

An Ansible role has a specific directory structure that helps organize various components. Here’s a typical directory layout:

```plaintext
roles/
  └── role_name/
      ├── defaults/
      │   └── main.yml      # Default variables for the role
      ├── files/
      │   └── file1         # Static files to be deployed
      ├── handlers/
      │   └── main.yml      # Handlers for the role
      ├── meta/
      │   └── main.yml      # Metadata about the role
      ├── tasks/
      │   └── main.yml      # Tasks to be executed by the role
      ├── templates/
      │   └── template1.j2  # Jinja2 templates for dynamic content
      └── vars/
          └── main.yml      # Variables specific to the role
```

### Creating and Using Roles

1. **Create a Role:**

   Use the `ansible-galaxy` command to create a new role skeleton:

   ```bash
   ansible-galaxy init role_name
   ```

   This command will generate the directory structure for `role_name`.

2. **Define Role Components:**

   - **`defaults/main.yml`**: Define default variables for the role.
   - **`files/`**: Store static files that will be copied to target nodes.
   - **`handlers/main.yml`**: Define handlers that can be triggered by tasks.
   - **`meta/main.yml`**: Include metadata about the role, such as dependencies.
   - **`tasks/main.yml`**: Define the main tasks to be executed.
   - **`templates/`**: Store Jinja2 templates used for dynamic configuration files.
   - **`vars/main.yml`**: Define role-specific variables.

3. **Use the Role in a Playbook:**

   Reference the role in your playbook by specifying it under the `roles` section:

   ```yaml
   # playbook.yml
   - hosts: webservers
     roles:
       - role_name
   ```

---

## Scenarios for `webserver` and `appserver` Roles

### Scenario 1: Basic Configuration without Templates and Handlers

#### **Webserver Role**

1. **Create Role Directory Structure**

   ```bash
   mkdir -p ~/roles/webserver/{tasks,files}
   ```

2. **Define Tasks**

   - **`tasks/main.yml`**

     ```yaml
     ---
     - name: Install git
       yum:
         name: git
         state: present

     - name: Create /var/www/html directory
       file:
         path: /var/www/html
         state: directory
         mode: '0755'

     - name: Clone repository
       git:
         repo: 'https://github.com/AsthikDev/finexo-web-app.git'
         dest: /var/www/html
         version: main

     - name: Install httpd
       yum:
         name: httpd
         state: present

     - name: Copy httpd.conf file
       copy:
         src: httpd.conf
         dest: /etc/httpd/conf/httpd.conf

     - name: Start and enable httpd service
       systemd:
         name: httpd
         state: started
         enabled: yes
     ```

3. **Configuration File**

   - **`files/httpd.conf`**

     ```plaintext
     Listen 80
     ```

4. **Problems with Basic Configuration:**

   - **Manual Restarts:** Each time you modify `httpd.conf`, you must restart the `httpd` service manually. This can be inefficient and error-prone.
   - **Lack of Dynamic Configuration:** Any changes in configuration require manual updates and service restarts.

#### **Appserver Role**

1. **Create Role Directory Structure**

   ```bash
   mkdir -p ~/roles/appserver/{tasks,files}
   ```

2. **Define Tasks**

   - **`tasks/main.yml`**

     ```yaml
     ---
     - name: Create /var/www/app directory
       file:
         path: /var/www/app
         state: directory
         mode: '0755'

     - name: Clone repository
       git:
         repo: 'https://github.com/AsthikDev/mediplus-web-app.git'
         dest: /var/www/app
         version: main

     - name: Install httpd
       yum:
         name: httpd
         state: present

     - name: Copy httpd.conf file
       copy:
         src: httpd.conf
         dest: /etc/httpd/conf/httpd.conf

     - name: Start and enable httpd service
       systemd:
         name: httpd
         state: started
         enabled: yes
     ```

3. **Configuration File**

   - **`files/httpd.conf`**

     ```plaintext
     Listen 443
     DocumentRoot "/var/www/app"
     DirectoryIndex app.html
     ```

4. **Problems with Basic Configuration:**

   - **Manual Restarts:** Configuration changes require manual service restarts.
   - **Static Configuration:** Configuration changes are hardcoded and not dynamically adjustable.

### Scenario 2: Configuration with Handlers and Notifiers

#### **Webserver Role with Handlers**

1. **Define Handlers**

   - **`handlers/main.yml`**

     ```yaml
     ---
     - name: restart httpd
       systemd:
         name: httpd
         state: restarted
     ```

2. **Modify Tasks to Use Notifiers**

   - **`tasks/main.yml`**

     ```yaml
     ---
     - name: Install git
       yum:
         name: git
         state: present

     - name: Create /var/www/html directory
       file:
         path: /var/www/html
         state: directory
         mode: '0755'

     - name: Clone repository
       git:
         repo: 'https://github.com/AsthikDev/finexo-web-app.git'
         dest: /var/www/html
         version: main

     - name: Install httpd
       yum:
         name: httpd
         state: present

     - name: Copy httpd.conf file
       copy:
         src: httpd.conf
         dest: /etc/httpd/conf/httpd.conf
       notify: restart httpd

     - name: Start and enable httpd service
       systemd:
         name: httpd
         state: started
         enabled: yes
     ```

3. **Benefits with Handlers:**

   - **Automatic Restarts:** The `httpd` service is restarted automatically only when the configuration file changes.
   - **Efficiency:** Reduces unnecessary service restarts, improving efficiency.

#### **Appserver Role with Handlers**

1. **Define Handlers**

   - **`handlers/main.yml`**

     ```yaml
     ---
     - name: restart httpd
       systemd:
         name: httpd
         state: restarted
     ```

2. **Modify Tasks to Use Notifiers**

   - **`tasks/main.yml`**

     ```yaml
     ---
     - name: Create /var/www/app directory
       file:
         path: /var/www/app
         state: directory
         mode: '0755'

     - name: Clone repository
       git:
         repo: 'https://github.com/AsthikDev/mediplus-web-app.git'
         dest: /var/www/app
         version: main

     - name: Install httpd
       yum:
         name: httpd
         state: present

     - name: Copy httpd.conf file
       copy:
         src: httpd.conf
         dest: /etc/httpd/conf/httpd.conf
       notify: restart httpd

     - name: Start and enable httpd service
       systemd:
         name: httpd
         state: started
         enabled: yes
     ```

3. **Benefits with Handlers:**

   - **Automatic Restarts:** The `httpd` service is restarted only when the configuration file changes.
   - **Reduced Downtime:** Ensures the service is restarted only when necessary, reducing potential downtime.

### Scenario 3: Configuration with Templates

#### **Webserver Role with Templates**

1. **Define a Jinja2 Template**

   - **`templates/httpd.conf.j2`**

     ```jinja2
     Listen {{ http_port }}
     ```

2. **Modify Tasks to Use Template**

   - **`tasks/main.yml`**

     ```yaml
     ---
     - name: Install git
       yum:
         name: git
         state: present

     - name: Create /var/www/html directory
       file:
         path: /var/www/html
         state: directory
         mode: '0755'

     - name: Clone repository
       git:
         repo: 'https://github.com/AsthikDev/finexo-web-app.git'
         dest: /var/www/html
         version: main

     - name: Install httpd
       yum:
         name: httpd
         state: present

     - name: Deploy httpd.conf from template
       template:
         src: httpd.conf.j2
         dest: /etc/httpd/conf/httpd.conf
       notify: restart httpd

     - name: Start and enable httpd service
       systemd:
         name: httpd
         state: started
         enabled: yes
     ```

3. **Define Variables**

   - **`vars/main.yml`**

     ```yaml
     ---
     http_port: 80
     ```

4. **Benefits with Templates:**

   - **Dynamic Configuration:** Use variables in templates to customize configurations.
   - **Scalability:** Easily manage configuration changes across multiple environments.

#### **Appserver Role with Templates**

1. **Define a Jinja2 Template**

   - **`templates/httpd.conf.j2`**

     ```jinja2
     Listen {{ http_port }}
     DocumentRoot "{{ document_root }}"
     DirectoryIndex {{ index_file }}
     ```

2. **Modify Tasks to Use Template**

   - **`tasks/main.yml`**

     ```yaml
     ---
     - name: Create /var/www/app directory
       file:
         path: /var/www/app
         state: directory
         mode: '0755'

     - name: Clone repository
       git:
         repo: 'https://github.com/AsthikDev/mediplus-web-app.git'
         dest: /var/www/app
         version: main

     - name: Install httpd
       yum:
         name: httpd
         state: present

     - name: Deploy httpd.conf from template
       template:
         src: httpd.conf.j2
         dest: /etc/httpd/conf/httpd.conf
       notify: restart httpd

     - name: Start and enable httpd service
       systemd:
         name: httpd
         state: started
         enabled: yes
     ```

3. **Define Variables**

   - **`vars/main.yml`**

     ```yaml
     ---
     http_port: 443
     document_root: /var/www/app
     index_file: app.html
     ```

4. **Benefits with Templates:**

   - **Dynamic Configuration:** Flexibly adjust configurations based on variables.
   - **Efficient Management:** Simplify management and deployment of configurations across different environments.

---

## Ansible Vault

**Ansible Vault** is a feature that allows you to encrypt sensitive data such as passwords, API keys, or other confidential information used in your Ansible playbooks and roles. The primary benefit of using Ansible Vault is to secure this sensitive data from unauthorized access while maintaining its usability in your automation tasks.

### Key Features

1. **AES-256 Encryption:** Ansible Vault uses AES-256 encryption to secure your files. This is a strong encryption standard that ensures data confidentiality.
2. **Password Protection:** Encrypted files are protected with a password. This password is required to encrypt and decrypt the data.
3. **Seamless Integration:** Encrypted data can be used within playbooks and roles without requiring changes to your existing playbook logic.

---

## How to Use Ansible Vault

### Encrypting Files

To encrypt a file, follow these steps:

1. **Create a File to Encrypt**

   Create a file containing sensitive data. For example, create a file named `secrets.yml`:

   ```yaml
   # secrets.yml
   db_password: "supersecretpassword"
   api_key: "1234567890abcdef"
   ```

2. **Encrypt the File**

   Use the `ansible-vault encrypt` command:

   ```bash
   ansible-vault encrypt secrets.yml
   ```

   You will be prompted to enter a password. This password is used for encrypting and decrypting the file.

3. **Verify Encryption**

   You can verify that the file is encrypted by viewing its contents:

   ```bash
   cat secrets.yml
   ```

   The output should be encrypted data.

### Decrypting Files

To decrypt a file, use:

```bash
ansible-vault decrypt secrets.yml
```

You will be prompted for the encryption password. Once decrypted, the file will be restored to its original, unencrypted state.

### Editing Encrypted Files

To edit an encrypted file directly without decrypting it to a separate file, use:

```bash
ansible-vault edit secrets.yml
```

This command opens the file in your default text editor. Changes will be saved in an encrypted format.

### Viewing Encrypted Files

To view the contents of an encrypted file, use:

```bash
ansible-vault view secrets.yml
```

This command allows you to see the decrypted contents without permanently decrypting the file.

### Using Encrypted Files in Playbooks

To use encrypted files in your playbooks, specify the vault password when running the playbook:

```bash
ansible-playbook playbook.yml --ask-vault-pass
```

Alternatively, use a password file to automate this process:

```bash
ansible-playbook playbook.yml --vault-password-file ~/.vault_pass.txt
```

---

## Incorporating Ansible Vault into Webserver and Appserver Roles

### 1. Encrypting Sensitive Data

#### **Encrypt HTTPD Configuration File**

1. **Create HTTPD Configuration Template**

   Create an HTTPD configuration template with sensitive variables. For example:

   - **`roles/webserver/templates/httpd.conf.j2`**

     ```apache
     Listen {{ http_port }}
     DocumentRoot "/var/www/html"
     ```

2. **Encrypt the Template**

   Encrypt the file:

   ```bash
   ansible-vault encrypt roles/webserver/templates/httpd.conf.j2
   ```

   This command will prompt you for a password. The encrypted template will be stored securely.

#### **Encrypt Variables File**

1. **Create Variables File**

   Create a variables file with sensitive data:

   - **`roles/webserver/vars/secret_vars.yml`**

     ```yaml
     ---
     http_port: 80
     admin_password: "supersecretpassword"
     ```

2. **Encrypt the Variables File**

   Encrypt the file:

   ```bash
   ansible-vault encrypt roles/webserver/vars/secret_vars.yml
   ```

### 2. Modifying Roles to Use Encrypted Data

#### **Webserver Role**

1. **Update `tasks/main.yml`**

   Use the encrypted configuration template in the webserver role:

   - **`roles/webserver/tasks/main.yml`**

     ```yaml
     ---
     - name: Install git
       yum:
         name: git
         state: present

     - name: Create /var/www/html directory
       file:
         path: /var/www/html
         state: directory
         mode: '0755'

     - name: Clone repository
       git:
         repo: 'https://github.com/AsthikDev/finexo-web-app.git'
         dest: /var/www/html
         version: main

     - name: Install httpd
       yum:
         name: httpd
         state: present

     - name: Deploy httpd.conf from template
       template:
         src: httpd.conf.j2
         dest: /etc/httpd/conf/httpd.conf
       notify: restart httpd

     - name: Start and enable httpd service
       systemd:
         name: httpd
         state: started
         enabled: yes
     ```

2. **Include Encrypted Variables**

   - **`roles/webserver/vars/main.yml`**

     This file remains empty, as variables are provided by the encrypted `secret_vars.yml`:

     ```yaml
     ---
     # Encrypted variables file is included in the playbook
     ```

   - **Include Encrypted Variables in Playbook**

     - **`playbook.yml`**

       ```yaml
       - hosts: webservers
         roles:
           - role: webserver
             vars_files:
               - roles/webserver/vars/secret_vars.yml
       ```

#### **Appserver Role**

1. **Update `tasks/main.yml`**

   Use the encrypted configuration template in the appserver role:

   - **`roles/appserver/tasks/main.yml`**

     ```yaml
     ---
     - name: Create /var/www/app directory
       file:
         path: /var/www/app
         state: directory
         mode: '0755'

     - name: Clone repository
       git:
         repo: 'https://github.com/AsthikDev/mediplus-web-app.git'
         dest: /var/www/app
         version: main

     - name: Install httpd
       yum:
         name: httpd
         state: present

     - name: Deploy httpd.conf from template
       template:
         src: httpd.conf.j2
         dest: /etc/httpd/conf/httpd.conf
       notify: restart httpd

     - name: Start and enable httpd service
       systemd:
         name: httpd
         state: started
         enabled: yes
     ```

2. **Include Encrypted Variables**

   - **`roles/appserver/vars/main.yml`**

     This file remains empty, as variables are provided by the encrypted `secret_vars.yml`:

     ```yaml
     ---
     # Encrypted variables file is included in the playbook
     ```

   - **Include Encrypted Variables in Playbook**

     - **`playbook.yml`**

       ```yaml
       - hosts: appservers
         roles:
           - role: appserver
             vars_files:
               - roles/appserver/vars/secret_vars.yml
       ```

### 3. Running the Playbook with Vault

To run the playbook and use encrypted data, provide the vault password:

1. **Using Password Prompt**

   ```bash
   ansible-playbook playbook.yml --ask-vault-pass
   ```

   You will be prompted to enter the vault password.

2. **Using Password File**

   ```bash
   ansible-playbook playbook.yml --vault-password-file ~/.vault_pass.txt
   ```

   Ensure that `~/.vault_pass.txt` contains the vault password.

### Summary of Best Practices

1. **Encrypt Sensitive Data:** Always encrypt files containing sensitive information such as passwords or API keys to prevent unauthorized access.
2. **Use a Password File:** Store the vault password in a secure file and use it to automate playbook execution. Ensure that the password file is protected and accessible only to authorized users.
3. **Maintain Confidentiality:** Regularly update and manage vault passwords to ensure continued security. Avoid hardcoding passwords or sensitive data in playbooks.
4. **Integrate Securely:** Use encrypted variables and files within playbooks and roles without altering the playbook logic. This ensures that sensitive data remains protected while maintaining ease of use.

By incorporating Ansible Vault, you enhance the security of your automation processes, ensuring that sensitive data is protected and managed effectively. This approach aligns with best practices for securing automation workflows and maintaining data confidentiality.

---

## **Integration of Ansible Vault into Multi-Environment Deployment**

### **1. Expanding Variables for Flexibility**

**Objective**: Ensure that the role configurations are adaptable to different environments and operating systems by defining various variables.

#### **1.1: `vars/main.yml` File**

**Purpose**: Store general configuration variables for the `webserver` role that can be overridden by environment-specific variables.

**Command**: 
```bash
nano ~/roles/webserver/vars/main.yml
```

**Content**:
```yaml
---
# Web server configuration
http_port: 80                # The port on which the web server will listen for HTTP requests.
https_port: 443               # The port on which the web server will listen for HTTPS requests.
doc_root: "/var/www/html"     # The root directory where web application files will be served from.
server_name: "example.com"   # The domain name for the web server.

# Application details
app_repo: "https://github.com/AsthikDev/finexo-web-app.git"  # URL of the Git repository for the web application.
app_version: "main"          # Branch or version of the application to be checked out from the repository.

# Package names (will be overridden for Ubuntu)
web_server_package: "httpd"  # The name of the package to be installed for the web server (e.g., httpd for CentOS).
web_server_service: "httpd"  # The name of the service to be managed for the web server.
http_conf_path: "/etc/httpd/conf/httpd.conf"  # Path to the HTTP server configuration file.
```

- **`http_port`**: This specifies the port on which HTTP traffic will be served. It is crucial for web server operations.
- **`https_port`**: This specifies the port for HTTPS traffic, ensuring encrypted communication.
- **`doc_root`**: Defines the directory where web content is stored. This is the base directory served by the web server.
- **`server_name`**: Used in server configuration to define the domain name of the server.
- **`app_repo`**: URL for cloning the application repository. This allows for version control and easy updates.
- **`app_version`**: Specifies which branch or tag of the repository to use, ensuring the correct version is deployed.
- **`web_server_package`**: The package name for the web server software. Different distributions may have different package names.
- **`web_server_service`**: The name of the service to manage (start, stop) for the web server.
- **`http_conf_path`**: The configuration file path used to modify server settings.

#### **1.2: `defaults/main.yml` File**

**Purpose**: Set default values for variables that may be overridden in environment-specific configurations.

**Command**: 
```bash
nano ~/roles/webserver/defaults/main.yml
```

**Content**:
```yaml
---
# Environment-specific settings
environment: "development"   # The current environment for the deployment, such as development, staging, or production.

# Feature flags
enable_ssl: false            # Flag to enable or disable SSL (HTTPS). Default is false for development environments.
enable_monitoring: false     # Flag to enable or disable monitoring tools. Default is false.
```

- **`environment`**: Helps in configuring settings specific to different stages of deployment (e.g., development, staging).
- **`enable_ssl`**: A boolean flag indicating whether SSL should be enabled. SSL is typically enabled in production environments.
- **`enable_monitoring`**: A boolean flag for enabling or disabling monitoring tools to check server performance or health.

---

### **2. Implementing Conditionals for Different Operating Systems**

**Objective**: Handle different configurations based on the operating system in use.

#### **2.1: `tasks/main.yml` File**

**Purpose**: Define the main tasks for the `webserver` role, including OS-specific configurations.

**Command**: 
```bash
nano ~/roles/webserver/tasks/main.yml
```

**Content**:
```yaml
---
- name: Include OS-specific variables
  include_vars: "{{ ansible_os_family }}.yml"
  # Dynamically includes variables based on the operating system family (RedHat or Debian).

- name: Install web server package
  package:
    name: "{{ web_server_package }}"  # Uses the variable defined for the package name, allowing flexibility.
    state: present  # Ensures the package is installed. If it's not installed, it will be added.

- name: Ensure web server is started and enabled
  service:
    name: "{{ web_server_service }}"  # Manages the web server service using the variable-defined name.
    state: started  # Ensures the service is running.
    enabled: yes  # Ensures the service is set to start at boot.

- name: Clone application repository
  git:
    repo: "{{ app_repo }}"  # URL for the Git repository.
    dest: "{{ doc_root }}"  # Directory where the repository will be cloned.
    version: "{{ app_version }}"  # Specifies which branch/version to checkout.

- name: Configure web server
  template:
    src: "{{ ansible_os_family }}_http.conf.j2"  # Template file for the HTTP configuration, specific to the OS.
    dest: "{{ http_conf_path }}"  # Destination path for the configuration file.
  notify: Restart web server  # Triggers a handler to restart the web server if this task makes changes.

- name: Open firewall ports (RedHat)
  firewalld:
    port: "{{ http_port }}/tcp"  # Opens the port for HTTP traffic in the firewall.
    permanent: yes  # Ensures the change persists after a reboot.
    state: enabled  # Enables the firewall rule.
  when: ansible_os_family == "RedHat"  # Only executes this task if the OS is RedHat-based.

- name: Open firewall ports (Ubuntu)
  ufw:
    rule: allow
    port: "{{ http_port }}"  # Allows traffic on the HTTP port through the firewall.
  when: ansible_os_family == "Debian"  # Only executes this task if the OS is Debian-based.
```

- **`include_vars`**: Includes a YAML file with OS-specific variables. `ansible_os_family` determines which file is included.
- **`package`**: Ensures the specified package is installed.
- **`service`**: Manages the web server service, ensuring it’s both started and enabled to start on boot.
- **`git`**: Clones the application repository into the specified directory.
- **`template`**: Applies a Jinja2 template to generate configuration files. This template is OS-specific.
- **`firewalld`**: Manages firewall settings for RedHat-based systems using `firewalld`.
- **`ufw`**: Manages firewall settings for Debian-based systems using `ufw`.

#### **2.2: OS-Specific Variable Files**

**For RedHat-based systems**:

**Command**: 
```bash
nano ~/roles/webserver/vars/RedHat.yml
```

**Content**:
```yaml
---
web_server_package: "httpd"  # Package name for the web server on RedHat-based systems.
web_server_service: "httpd"  # Service name for the web server on RedHat-based systems.
http_conf_path: "/etc/httpd/conf/httpd.conf"  # Path to the HTTPD configuration file.
```

**For Debian-based systems**:

**Command**: 
```bash
nano ~/roles/webserver/vars/Debian.yml
```

**Content**:
```yaml
---
web_server_package: "apache2"  # Package name for the web server on Debian-based systems.
web_server_service: "apache2"  # Service name for the web server on Debian-based systems.
http_conf_path: "/etc/apache2/apache2.conf"  # Path to the Apache configuration file.
```

- **`web_server_package`**: Defines the package name for the web server software specific to the OS.
- **`web_server_service`**: Defines the service name for managing the web server.
- **`http_conf_path`**: Path to the main configuration file for the web server.

---

### **3. Adding Pre and Post Tasks for Checks**

**Objective**: Implement pre-deployment checks and post-deployment verifications to ensure a smooth deployment process.

#### **3.1: `pre_tasks.yml` File**

**Purpose**: Perform preliminary checks before executing the main tasks.

**Command**: 
```bash
nano ~/roles/webserver/tasks/pre_tasks.yml
```

**Content**:
```yaml
---
- name: Check if required ports are available
  wait_for:
    port: "{{ http_port }}"  # Port to check for availability.
    state: stopped  # Ensures the port is not currently in use.
    timeout: 1  # Timeout in seconds for the check.

- name: Ensure required directories exist
  file:
    path: "{{ doc_root }}"  # Directory to check/create.
    state: directory  # Ensures the path is a directory.
    mode: '0755'  # Sets permissions for the directory (read/write/execute for owner, read/execute for others).

- name: Check if Git is installed
  command: which git  # Checks the presence of Git.
  register: git_check  # Captures the result of the command.
  ignore_errors: yes  # Continues execution even if the command fails.
 

 failed_when: git_check.stdout == ""  # Fails the task if Git is not found.
```

- **`wait_for`**: Waits for the specified port to be available, ensuring no conflicts.
- **`file`**: Ensures that directories exist with the correct permissions.
- **`command`**: Executes a command to check if Git is installed and handles errors gracefully.

#### **3.2: `post_tasks.yml` File**

**Purpose**: Perform tasks after the main deployment to ensure everything is correctly set up.

**Command**: 
```bash
nano ~/roles/webserver/tasks/post_tasks.yml
```

**Content**:
```yaml
---
- name: Verify web server is running
  service_facts:  # Gathers facts about services on the host.
  register: services_facts  # Stores the gathered facts.

- name: Check if HTTPD service is running
  assert:
    that:
      - "'httpd' in services_facts.services"  # Verifies if the HTTPD service is listed.
      - "services_facts.services['httpd'].state == 'running'"  # Ensures the HTTPD service is running.
    fail_msg: "HTTPD service is not running"  # Error message if the assertion fails.

- name: Notify successful deployment
  debug:
    msg: "Web server deployed successfully!"  # Outputs a success message.
```

- **`service_facts`**: Gathers facts about all services to verify the status of the web server service.
- **`assert`**: Verifies conditions to ensure the web server service is running as expected.
- **`debug`**: Outputs a message indicating successful deployment.

---

### **4. Implementing Error Handling and Logging**

**Objective**: Ensure robust error handling and logging for deployment issues.

#### **4.1: `handlers/main.yml` File**

**Purpose**: Define handlers that respond to specific changes or errors.

**Command**: 
```bash
nano ~/roles/webserver/handlers/main.yml
```

**Content**:
```yaml
---
- name: Restart web server
  service:
    name: "{{ web_server_service }}"  # Service to be restarted.
    state: restarted  # Restarts the service to apply changes.

- name: Log deployment error
  lineinfile:
    path: /var/log/ansible_deploy.log  # Log file path.
    line: "{{ ansible_date_time.iso8601 }} - Deployment failed: {{ ansible_failed_task }}"  # Log entry format.
    create: yes  # Creates the log file if it does not exist.
```

- **`service`**: Manages the service to restart it, often used to apply configuration changes.
- **`lineinfile`**: Appends error messages to a log file for tracking deployment issues.

#### **4.2: `block` with `rescue`**

**Purpose**: Group tasks with error handling to ensure failures are managed effectively.

**Command**: 
```bash
nano ~/roles/webserver/tasks/main.yml
```

**Content**:
```yaml
---
- block:
    - name: Clone application repository
      git:
        repo: "{{ app_repo }}"
        dest: "{{ doc_root }}"
        version: "{{ app_version }}"

    - name: Configure web server
      template:
        src: "{{ ansible_os_family }}_http.conf.j2"
        dest: "{{ http_conf_path }}"
      notify: Restart web server

  rescue:
    - name: Notify failure
      meta: end_play  # Ends the play if an error occurs.
      delegate_to: localhost  # Executes the notification on the localhost.
      notify: Log deployment error  # Triggers the error logging handler.
```

- **`block`**: Groups related tasks together, allowing collective error handling.
- **`rescue`**: Handles errors by performing specific tasks, such as logging the error and ending the play.

---

### **5. Integrating Ansible Vault**

**Objective**: Securely manage sensitive information using Ansible Vault.

#### **5.1: Encrypting Sensitive Data**

**Purpose**: Create an encrypted file to store sensitive data such as passwords and API keys.

**Command**: 
```bash
ansible-vault create ~/roles/webserver/vars/secrets.yml
```

**Content**:
```yaml
---
db_password: "securepassword"  # Encrypted database password.
api_key: "supersecretapikey"   # Encrypted API key.
```

- **`ansible-vault create`**: Creates and encrypts a file for sensitive information.

**Note**: You will be prompted to enter a password for encryption. Store this password securely.

#### **5.2: Updating `vars/main.yml` to Include Encrypted Variables**

**Purpose**: Reference encrypted variables within the role’s variable files.

**Command**: 
```bash
nano ~/roles/webserver/vars/main.yml
```

**Content**:
```yaml
---
# Web server configuration
http_port: 80
https_port: 443
doc_root: "/var/www/html"
server_name: "example.com"

# Application details
app_repo: "https://github.com/AsthikDev/finexo-web-app.git"
app_version: "main"

# Package names (will be overridden for Ubuntu)
web_server_package: "httpd"

# Encrypted secrets
db_password: "{{ vault_db_password }}"  # Referencing the encrypted database password.
api_key: "{{ vault_api_key }}"  # Referencing the encrypted API key.
```

- **`{{ vault_db_password }}`**: Uses the encrypted variable from `secrets.yml`.
- **`{{ vault_api_key }}`**: Uses the encrypted variable from `secrets.yml`.

##### **5.3: Updating Playbook to Use Vault**

**Purpose**: Include encrypted variables in the playbook.

**Command**: 
```bash
nano ~/playbooks/webserver_deploy.yml
```

**Content**:
```yaml
---
- hosts: webservers
  vars_files:
    - ~/roles/webserver/vars/secrets.yml  # Includes the encrypted secrets.
  vars:
    environment: production
    enable_ssl: true
  roles:
    - webserver
```

- **`vars_files`**: Specifies the file containing encrypted variables to be included in the playbook.

#### **5.4: Running Playbook with Vault Password**

**Purpose**: Execute the playbook using the Vault password to decrypt sensitive data.

**Command**: 
```bash
ansible-playbook ~/playbooks/webserver_deploy.yml --vault-password-file ~/.vault_pass.txt
```

- **`--vault-password-file`**: Specifies the file containing the Vault password for decryption.

---

### **Summary**

This expanded guide provides detailed steps for integrating Ansible Vault into a multi-environment deployment scenario, covering:

1. **Expanded Variables**: Detailed explanation of variables used in `vars/main.yml` and `defaults/main.yml`.
2. **Conditionals for OS Families**: Explanation of tasks and variables for different OS families.
3. **Pre and Post Tasks**: Comprehensive details on pre-deployment checks and post-deployment verifications.
4. **Error Handling and Logging**: In-depth description of error handling strategies, including `block`, `rescue`, and logging.
5. **Ansible Vault Integration**: Detailed steps for encrypting sensitive data, updating configuration files, and running playbooks with Vault.

Each step ensures a robust, secure, and adaptable deployment process, with clear explanations of parameters and commands.

---

## **Understanding Ansible Modules**

### **What is an Ansible Module?**

Ansible modules are essential components of Ansible's architecture, serving as the building blocks for executing tasks across a wide range of environments. Each module is a self-contained unit of code that performs specific functions like managing packages, configuring services, or handling files. Modules abstract the complexities of system administration by providing a simplified interface that ensures consistency and reliability across different platforms.

### **Key Features of Ansible Modules:**

- **Idempotence**: This is one of the core principles of Ansible modules. An idempotent module ensures that a task can be run multiple times without changing the system state if it’s already in the desired state. For example, if you use the `yum` module to install a package, it won’t reinstall the package if it’s already present.

- **Cross-Platform Compatibility**: Ansible modules are designed to work across various operating systems, including different Linux distributions, Windows, and network devices. This allows you to write automation scripts that are portable and reusable across different environments.

- **Extensibility**: While Ansible includes hundreds of built-in modules, it also allows you to create custom modules if the existing ones don’t meet your needs. This flexibility is crucial for tailoring automation processes to fit specific organizational requirements.

### **Commonly Used Ansible Modules:**

- **`yum`**: This module is used for managing packages on RPM-based distributions like Red Hat and CentOS. It allows you to install, remove, and manage packages on target systems.

- **`apt`**: Similar to `yum`, but for Debian-based distributions like Ubuntu. It provides a way to manage packages using the APT package manager.

- **`git`**: This module is used for interacting with Git repositories. It can clone repositories, checkout specific branches, and manage repository states.

- **`copy`**: This module copies files from the control node (where Ansible is running) to the target node(s). It is useful for distributing static files like configuration files.

- **`template`**: This module is more advanced than `copy` as it allows you to use Jinja2 templates. These templates can include variables and conditional logic, making them highly flexible for generating dynamic configuration files.

- **`service`**: This module is used to manage services on target nodes. It can start, stop, restart, or reload services, ensuring they are in the desired state.

---

## **Incorporating the server deployment Scenario as an Ansible Module**

While Ansible modules are typically used to perform discrete tasks, you can also create custom modules to encapsulate more complex workflows. This is particularly useful when you need to combine multiple operations into a single, reusable component.

## **Step-by-Step Guide: Creating a Custom Ansible Module**

Creating a custom Ansible module involves writing a Python script that defines the tasks you want to automate. Below is a detailed, step-by-step explanation of how to create a custom Ansible module for deploying a web application.

### **Step 1: Determine the Purpose of the Module**

The first step is to clearly define what you want your module to do. In this case, the module should:

- Install the HTTPD service.
- Clone a Git repository containing the web application.
- Modify the HTTPD configuration file to change the listening port.
- Restart the HTTPD service to apply the changes.

### **Step 2: Set Up the Python Script**

Ansible custom modules are typically written in Python. Start by creating a directory to store your custom modules and then create a Python script for your module.

```bash
mkdir -p ~/ansible_custom_modules
cd ~/ansible_custom_modules
vim deploy_web_app.py
```

### **Step 3: Module Structure**

Begin by importing the necessary Ansible module utilities. These utilities provide a standardized way to interact with Ansible’s core functionalities.

```python
#!/usr/bin/python

from ansible.module_utils.basic import AnsibleModule
```

### **Step 4: Define the Module’s Logic**

This is where you define the parameters your module will accept and the core logic it will execute. The parameters are the inputs your module will use to perform its tasks, and they should be defined in a dictionary.

```python
def run_module():
    module_args = dict(
        git_repo=dict(type='str', required=True),  # The Git repository URL
        dest=dict(type='str', required=True),      # The destination directory on the target node
        http_port=dict(type='int', required=True), # The port number for HTTPD to listen on
        http_service=dict(type='str', required=True) # The name of the HTTPD service
    )
```

Next, initialize a `result` dictionary to store the outcome of the module’s execution.

```python
    result = dict(
        changed=False,
        original_message='',
        message=''
    )
```

Create the Ansible module object, which includes the parameters you defined earlier.

```python
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )
```

The module should handle `check_mode`, which is a feature in Ansible that allows you to see what changes would be made without actually applying them.

```python
    if module.check_mode:
        module.exit_json(**result)
```

### **Step 5: Implement the Core Logic**

Now, write the main logic for your module. This involves running shell commands on the target nodes to clone the Git repository, modify the HTTPD configuration, and restart the service.

```python
    # Clone the repository
    git_cmd = f"git clone {module.params['git_repo']} {module.params['dest']}"
    rc, out, err = module.run_command(git_cmd)

    if rc != 0:
        module.fail_json(msg=err)
    else:
        result['changed'] = True
        result['original_message'] = git_cmd
        result['message'] = out
```

In this example, `run_command` is used to execute the shell command on the target node. The command's return code (`rc`), standard output (`out`), and standard error (`err`) are captured. If the command fails (i.e., `rc != 0`), the module should return an error using `module.fail_json()`.

Continue with modifying the HTTPD configuration file and restarting the service.

```python
    # Update HTTPD configuration
    conf_path = '/etc/httpd/conf/httpd.conf'
    sed_cmd = f"sed -i 's/^Listen .*/Listen {module.params['http_port']}/' {conf_path}"
    rc, out, err = module.run_command(sed_cmd)

    if rc != 0:
        module.fail_json(msg=err)
    else:
        result['changed'] = True

    # Restart the HTTPD service
    service_cmd = f"systemctl restart {module.params['http_service']}"
    rc, out, err = module.run_command(service_cmd)

    if rc != 0:
        module.fail_json(msg=err)
    else:
        result['changed'] = True
```

### **Step 6: Complete the Module**

Finally, the module should return the result to Ansible. This is done using `module.exit_json()`, which takes the `result` dictionary as an argument.

```python
    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()
```

### **Complete Python script with all the above discussed modules:**

```python
#!/usr/bin/python

from ansible.module_utils.basic import AnsibleModule

def run_module():
    module_args = dict(
        git_repo=dict(type='str', required=True),  # The Git repository URL
        dest=dict(type='str', required=True),      # The destination directory on the target node
        http_port=dict(type='int', required=True), # The port number for HTTPD to listen on
        http_service=dict(type='str', required=True) # The name of the HTTPD service
    )

    result = dict(
        changed=False,
        original_message='',
        message=''
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    if module.check_mode:
        module.exit_json(**result)

    # Clone the repository
    git_cmd = f"git clone {module.params['git_repo']} {module.params['dest']}"
    rc, out, err = module.run_command(git_cmd)

    if rc != 0:
        module.fail_json(msg=err)
    else:
        result['changed'] = True
        result['original_message'] = git_cmd
        result['message'] = out

    # Update HTTPD configuration
    conf_path = '/etc/httpd/conf/httpd.conf'
    sed_cmd = f"sed -i 's/^Listen .*/Listen {module.params['http_port']}/' {conf_path}"
    rc, out, err = module.run_command(sed_cmd)

    if rc != 0:
        module.fail_json(msg=err)
    else:
        result['changed'] = True

    # Restart the HTTPD service
    service_cmd = f"systemctl restart {module.params['http_service']}"
    rc, out, err = module.run_command(service_cmd)

    if rc != 0:
        module.fail_json(msg=err)
    else:
        result['changed'] = True

    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()
```


### **Step 7: Deploy the Custom Module**

Once your module script is complete, you need to make it available to Ansible. You can either place it in a system-wide directory like `/usr/share/ansible/plugins/modules/` or specify a custom path in your playbook.

```bash
export ANSIBLE_LIBRARY=~/ansible_custom_modules/
```

### **Step 8: Using the Custom Module in a Playbook**

Now that your module is ready, create a playbook that uses it. This playbook will execute the module on your target nodes.

```yaml
---
- name: Deploy Web Application Using Custom Module
  hosts: webserver
  become: yes
  tasks:
    - name: Deploy Web App
      deploy_web_app:
        git_repo: "https://github.com/AsthikDev/finexo-web-app.git"
        dest: "/var/www/html"
        http_port: 80
        http_service: "httpd"
```

### **Step 9: Run the Playbook**

To execute the playbook, use the following command:

```bash
ansible-playbook custom_module_playbook.yml -u ansible
```

This will trigger the tasks defined in your custom module, automating the deployment of your web application.

---

## **Advantages and Disadvantages of Using Custom Modules**

### **Advantages**:
- **Customization**: Custom modules allow you to tailor Ansible to meet specific needs that might not be covered by existing modules.
- **Reusability**: Once written, custom modules can be reused across different playbooks and projects, reducing duplication of effort.
- **Efficiency**: By encapsulating complex processes in a single module, you can reduce the number of tasks and simplify your playbooks.

### **Disadvantages**:
- **Complexity**: Writing custom modules can be complex, especially for those unfamiliar with Python or Ansible’s internal workings.
- **Testing and Debugging**: Custom modules require thorough testing to ensure they work as expected. Debugging can also be more challenging compared to using built-in modules.
- **Maintenance**: Custom modules need to be maintained over time, especially as Ansible evolves. This includes updating the code to remain compatible with newer versions of Ansible.

---

## **Ansible Galaxy**

### **Introduction to Ansible Galaxy**

Ansible Galaxy is a community-driven platform where developers can share, download, and manage Ansible roles. It functions similarly to a package manager for Ansible roles, enabling users to find and leverage pre-built roles to automate various tasks, such as setting up web servers, managing databases, and more.

### **Key Features of Ansible Galaxy:**

1. **Role Repository**:
   - Ansible Galaxy hosts a vast repository of roles created by the community and certified by Ansible. Users can browse and install these roles, which are pre-configured to perform specific tasks, significantly reducing the time and effort required to write automation scripts from scratch.

2. **Role Versioning**:
   - Ansible Galaxy supports version control, allowing users to specify and use particular versions of a role. This feature is crucial for maintaining stability in automation workflows, as it ensures that updates or changes to a role do not inadvertently break your playbooks.

3. **Role Dependencies**:
   - Roles in Galaxy can define dependencies on other roles. This capability streamlines complex setups by automatically installing all necessary roles required for a particular task, ensuring that your environment is configured correctly.

---

## **Using Ansible Galaxy**

### **1. Searching for Roles on Ansible Galaxy**

Before you can install a role, you need to find one that suits your needs. You can search for roles directly on the Ansible Galaxy website or via the command line.

- **Search on the Website**:
  - Visit [Ansible Galaxy](https://galaxy.ansible.com/) and use the search bar to find roles by name, keyword, or tag.

- **Search via Command Line**:
  - You can also search for roles directly from the command line using the `ansible-galaxy search` command.
  
  ```bash
  ansible-galaxy search webserver
  ```

  - **Explanation**:
    - This command searches the Galaxy repository for roles related to "webserver" and lists them with their descriptions, author names, and other details.

### **2. Installing a Role from Ansible Galaxy**

Once you’ve identified a role, you can install it using the `ansible-galaxy install` command.

- **Command Example**:

  ```bash
  ansible-galaxy install geerlingguy.apache
  ```

  - **Explanation**:
    - This command installs the `geerlingguy.apache` role, which is commonly used for setting up an Apache HTTP server. The role is downloaded to the default roles directory, typically `~/.ansible/roles/`, unless otherwise specified.

- **Role Installation Directory**:
  - By default, roles are installed into `~/.ansible/roles/` or `/etc/ansible/roles/` if installed system-wide. You can specify a different path using the `-p` option:
  
  ```bash
  ansible-galaxy install geerlingguy.apache -p /custom/path/roles
  ```

### **3. Using a Galaxy Role in a Playbook**

After installing a role, it can be utilized in your playbooks like any other role.

- **Playbook Example**:

  ```yaml
  ---
  - name: Deploy Web Server Using Apache Role from Galaxy
    hosts: webserver
    become: yes
    roles:
      - geerlingguy.apache
  ```

  - **Explanation**:
    - This playbook applies the `geerlingguy.apache` role to all hosts in the `webserver` group, setting up Apache HTTP Server with default configurations provided by the role.

### **4. Customizing Galaxy Roles**

Galaxy roles often come with default variables that can be overridden to suit your specific needs.

- **Playbook Example with Custom Variables**:

  ```yaml
  ---
  - name: Customize Apache Role Configuration
    hosts: webserver
    become: yes
    roles:
      - role: geerlingguy.apache
        vars:
          apache_listen_port: 8080
  ```

  - **Explanation**:
    - In this example, the `apache_listen_port` variable is set to `8080`, overriding the default port configuration provided by the `geerlingguy.apache` role.

### **5. Creating and Publishing a Role to Ansible Galaxy**

If you have created a role that you think could benefit others, you can publish it to Ansible Galaxy. The process involves initializing a role, creating the necessary files, and then importing it into Galaxy.

- **Step 1: Initialize a New Role Structure**:

  ```bash
  ansible-galaxy init my_custom_role
  ```

  - **Explanation**:
    - This command creates a directory structure for a new role named `my_custom_role`. The structure includes directories for tasks, handlers, variables, defaults, and more.

- **Step 2: Develop the Role**:
  - Customize the generated files to define the tasks, handlers, and variables needed for your role.

- **Step 3: Create an Account and Upload the Role**:
  - First, create an account on [Ansible Galaxy](https://galaxy.ansible.com/). Then, from your role directory, import the role into Galaxy.

  ```bash
  ansible-galaxy login
  ansible-galaxy role import GitHub_username my_custom_role
  ```

  - **Explanation**:
    - This command imports your role from a GitHub repository into Ansible Galaxy. Make sure your GitHub repository is structured correctly and has a `meta/main.yml` file that includes metadata about the role.

### **6. Best Practices for Using Ansible Galaxy**

When using or sharing roles on Ansible Galaxy, it’s essential to follow best practices to ensure reliability, maintainability, and security.

- **Review Code Before Use**:
  - Always review the source code of roles before using them in production environments. This helps you understand what the role does and ensures it aligns with your security and compliance requirements.

- **Manage Role Dependencies**:
  - Be mindful of role dependencies, as they can introduce unexpected changes or conflicts. Ensure that all dependencies are well-maintained and compatible with your environment.

- **Pin Specific Versions**:
  - Use specific versions of roles to avoid breaking changes that may occur in newer releases. This is done by specifying the version in the install command:

  ```bash
  ansible-galaxy install geerlingguy.apache,1.0.0
  ```

- **Customize Roles Locally**:
  - If a Galaxy role requires modifications to fit your needs, it’s better to fork the role and make changes locally rather than altering the role in the default directory. This preserves the original role for future updates.

- **Document Your Roles**:
  - When creating roles for Galaxy, include comprehensive documentation in a `README.md` file. This should explain what the role does, its variables, and usage examples.

- **Use Semantic Versioning**:
  - Follow semantic versioning practices (e.g., `1.0.0`, `1.1.0`, `2.0.0`) to make it easier for users to understand the nature of changes in your role (e.g., bug fixes, new features, or breaking changes).

- **Test Roles Thoroughly**:
  - Test your roles in different environments to ensure they work as expected. Automated testing using tools like Molecule can help streamline this process.

- **Keep Roles Modular**:
  - Design your roles to be focused and modular, handling specific tasks or services. This makes them easier to reuse and combine with other roles.
