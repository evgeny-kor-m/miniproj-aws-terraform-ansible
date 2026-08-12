# 🚀 Mini Project – AWS + Terraform + Ansible

## Extension for Terraform files

The solution is to install the official HashiCorp Terraform extension:   
```
1. Open Extensions (the cube icon on the left, or Ctrl+Shift+X)
2. Search for: HashiCorp Terraform
3. Install the HashiCorp extension (created by HashiCorp, not a third-party one)—it's called "HashiCorp Terraform."
4. After installation, restart VS Code (Ctrl+Shift+P → Developer: Reload Window)
```
Also useful: enable autoformatting and validation on the fly:   
```
In settings.json (Ctrl+Shift+P → Preferences: Open User Settings (JSON)):
json{
      "[terraform]": {
      "editor.defaultFormatter": "hashicorp.terraform",
      "editor.formatOnSave": true
      },
      "terraform.languageServer.enable": true
}
```
## 🎯 Project Overview

In this project you will build a complete AWS infrastructure using **Terraform** and automate server configuration and application deployment using **Ansible**.

The project will include:

* ☁️ AWS Infrastructure
* 🌐 VPC & Networking
* 🔐 Security Groups
* ⚖️ Application Load Balancer
* 🎯 Target Groups
* 🖥️ EC2 Instances
* 🗄️ Amazon EFS
* 🐳 Docker
* 📦 Amazon ECR
* 🔑 IAM Roles
* ⚙️ Ansible Automation
* 🗂️ Git

The project is divided into **5 main parts**.

---

# 📦 Part 1 – AWS Network Infrastructure with Terraform (25 Points)

## 🎯 Objective

Create the entire AWS networking infrastructure using **Terraform**.

Terraform must be responsible for creating and configuring all AWS infrastructure components.

---

## 🌐 VPC

Create a dedicated VPC.

The VPC must contain **4 subnets**:

* 2 Public Subnets
* 2 Private Subnets

The subnets should be distributed across at least **2 Availability Zones**.

---

## 🌍 Internet Gateway

Create and attach an:

```text
Internet Gateway (IGW)
```

The Internet Gateway must provide internet connectivity to resources located in the public subnets.

---

## 🔄 NAT Gateway

Create a:

```text
NAT Gateway
```

The NAT Gateway must allow resources located in the private subnets to access the internet.

For example:

* Install packages
* Pull Docker images
* Download dependencies

Private EC2 instances must not be directly accessible from the public internet.

---

## 🛣️ Route Tables

Configure the required route tables.

### Public Subnets

```text
Public Subnet
      ↓
Internet Gateway
      ↓
Internet
```

### Private Subnets

```text
Private Subnet
      ↓
NAT Gateway
      ↓
Internet Gateway
      ↓
Internet
```

---

## ⚠️ Terraform Requirement

All AWS infrastructure must be created using Terraform.

Do not manually create AWS resources through the AWS Console.

Terraform must manage:

* VPC
* Subnets
* Route Tables
* Internet Gateway
* NAT Gateway

---

# 🔐 Part 2 – Security Groups & AWS Components (25 Points)

## 🎯 Objective

Create the required AWS components using Terraform and secure communication between them.

---

## 🔒 Security Groups

Create dedicated Security Groups using Terraform.

At minimum, create Security Groups for:

* ALB
* Frontend
* Backend
* Ansible Master

Follow the principle of least privilege.

Example:

```text
Internet
   ↓
ALB : 80/443
   ↓
Backend : Application Port
   ↓
EFS : NFS 2049
```

The backend should only accept application traffic from the ALB Security Group.

The Ansible Master should only allow required management access.

---

## 🖥️ EC2 Instances

Terraform must create all required EC2 instances.  
```
How to check what LTS (Long Term Support) version currently relevant:
aws ec2 describe-images \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-*-amd64-server-*" \
            "Name=state,Values=available" \
  --query 'sort_by(Images, &CreationDate)[-5:].[Name,CreationDate]' \
  --output table \
  --region eu-west-1

Output:
-------------------------------------------------------------------------------------------------------
|                                           DescribeImages                                            |
+------------------------------------------------------------------------+----------------------------+
|  ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-20260714 |  2026-07-14T07:27:11.000Z  |  [v]
|  ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20260714    |  2026-07-14T11:54:28.000Z  |
|  ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-20260722 |  2026-07-22T08:12:24.000Z  |
|  ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-20260731 |  2026-07-31T06:23:36.000Z  |
|  ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-20260806 |  2026-08-06T07:34:13.000Z  |
+------------------------------------------------------------------------+----------------------------+
```
### Frontend Servers

Create:

```text
1 Frontend EC2 Instance
```

The frontend server must be located in the **public subnets**.

---

### Backend Servers

Create 2 backend EC2 instances in the **private subnets**.

The backend instances must:

* Not have public IP addresses
* Be registered in the Target Group
* Receive application traffic through the ALB

---

### Ansible Master

Create:

```text
1 Ansible Master EC2 Instance
```

The Ansible Master must be located in a **public subnets**.

The Ansible Master will manage the application servers using Ansible.

---

## 🎯 Target Group

Create a Target Group containing the backend EC2 instances.

The architecture should be:

```text
Internet
   ↓
ALB
   ↓
Target Group
   ↓
Backend EC2 Instances
```

---

## ⚖️ Application Load Balancer

Create an:

```text
Application Load Balancer (ALB)
```

The ALB must be deployed in the **public subnets**.

The ALB will receive incoming traffic and forward requests to the backend application.

---


# 🗄️ Part 3 – EFS & Application Deployment (25 Points)

## 🎯 Objective

Create persistent shared storage and deploy the application using Docker.

---

## 🗄️ Amazon EFS

Create an:

```text
Amazon EFS
```

using Terraform.

The EFS filesystem must be accessible from the backend EC2 instances.

Create the required EFS Mount Targets in the private subnets.

The backend servers must mount the EFS filesystem.

```
Troubleshooting : sudo cat /var/log/cloud-init-output.log | grep "mount\|efs|error"
terraform taint 'aws_instance.ec2-backend-param["1a"]'
terraform taint 'aws_instance.ec2-backend-param["1b"]'
terraform taint aws_instance.ec2-ansible-param
terraform apply

3.93.212.251    ansible  public
32.192.1.137  frontend   public

10.0.4.107  ec2-tf-backend-1b  private
10.0.3.252  ec2-tf-backend-1a  private

cd /mnt/e/DevOps/GIT/miniproj-aws-terraform-ansible/terraform

ssh -i /mnt/e/DevOps/GIT/miniproj-aws-terraform-ansible/terraform/aws-ssh-key.pem ubuntu@3.93.212.251      -  ansible
ssh -i /mnt/e/DevOps/GIT/miniproj-aws-terraform-ansible/terraform/aws-ssh-key.pem ubuntu@32.192.1.137     -  frontend

ssh -o ProxyCommand="ssh -i ./aws-ssh-key.pem -W %h:%p ubuntu@3.93.212.251" -i /mnt/e/DevOps/GIT/miniproj-aws-terraform-ansible/terraform/aws-ssh-key.pem ubuntu@10.0.4.107       -  ec2-tf-backend-1b
ssh -o ProxyCommand="ssh -i ./aws-ssh-key.pem -W %h:%p ubuntu@3.93.212.251" -i /mnt/e/DevOps/GIT/miniproj-aws-terraform-ansible/terraform/aws-ssh-key.pem ubuntu@10.0.3.252      -  ec2-tf-backend-1a


ssh -i ~/.ssh/aws-ssh-key.pem ansible@10.0.4.107
ssh -i ~/.ssh/aws-ssh-key.pem ansible@10.0.3.252
```


---

## 🐳 Backend Application

Deploy the backend application as a Docker container.

The backend application must:

* Run on private EC2 instances
* Be accessible through the ALB
* Run using Docker
* Mount the EFS filesystem where required

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 111314928072.dkr.ecr.us-east-1.amazonaws.com

docker build -t backend -f ./backend/Dockerfile .
docker tag backend:latest 111314928072.dkr.ecr.us-east-1.amazonaws.com/backend-img-tf:latest
docker push 111314928072.dkr.ecr.us-east-1.amazonaws.com/backend-img-tf:latest

---

## 🌐 Frontend Application

Deploy the frontend application on the public EC2 instances.

The frontend application must:

* Run as a Docker container
* Be accessible from the internet
* Communicate with the backend through the ALB

ssh -i aws-ssh-key.pem ubuntu@3.82.104.29

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 111314928072.dkr.ecr.us-east-1.amazonaws.com

docker build -t frontend -f ./frontend/Dockerfile .
docker tag frontend:latest 111314928072.dkr.ecr.us-east-1.amazonaws.com/frontend-img-tf:latest
docker push 111314928072.dkr.ecr.us-east-1.amazonaws.com/frontend-img-tf:latest

---

## 📦 Amazon ECR

Create an Amazon ECR repository using Terraform.

The application Docker images must be stored in:

```text
Amazon ECR
```

The deployment flow should be:

```text
Git Repository
      ↓
Docker Build
      ↓
Amazon ECR
      ↓
EC2 Instances
      ↓
Docker Run
```

---

# ⚙️ Part 4 – Ansible Automation (25 Points)

Ansible is responsible for **configuration and application deployment**.

---

## 📦 Required Installations

Ansible must install the following on the required EC2 instances:

* Docker
* Git

---

## 🚀 Application Deployment

Ansible must be responsible for:

1. Connecting to the EC2 instances
2. Installing Docker
3. Installing Git
4. Pulling the application source code
5. Authenticating with Amazon ECR
6. Pulling the required Docker image
7. Stopping the previous application container
8. Running the new Docker container

---

## 🐳 Docker Deployment

Ansible should manage the Docker container lifecycle.

Expected flow:

```text
Ansible Master
      ↓
Install Docker
      ↓
Install Git
      ↓
Authenticate with ECR
      ↓
Pull Docker Image
      ↓
Stop Old Container
      ↓
Run New Container
```

---

## 📁 Ansible Requirements

Create:

* Inventory file
* Installation Playbook
* Deployment Playbook
* Variables

Use Ansible variables to avoid duplicated tasks.

---

## 🔔 Handlers & Notify

Use Ansible:

```text
Handlers
+
Notify
```

for application deployment operations.

For example, when application configuration or deployment files change, notify a handler responsible for restarting or redeploying the Docker container.

Docker containers should not be restarted unnecessarily when no changes occur.

---

# 🏗️ Terraform Requirements

## 🎯 Objective

Terraform must manage the complete AWS infrastructure lifecycle.

---

## Terraform Must Create

At minimum:

```text
VPC
├── Public Subnet 1
├── Public Subnet 2
├── Private Subnet 1
└── Private Subnet 2

Internet Gateway
NAT Gateway
Route Tables
Security Groups

EC2
├── Ansible Master
├── Backend 1
├── Backend 2
└── Frontend Instance

Application Load Balancer
Target Group
Listeners

EFS
EFS Mount Targets

ECR Repository

IAM Roles
IAM Policies
Instance Profiles
```

---

# 🗂️ Git Requirements

Create a Git repository and manage the entire project code inside it.

The repository should contain:

* Terraform Code
* Ansible Playbooks
* Ansible Inventory
* Dockerfiles
* Application Source Code
* Infrastructure Configuration
* README.md

Use meaningful commit messages and maintain a clean repository structure.

---

# 📁 Recommended Folder Structure

```text
final-project/
│
├── terraform/
│   └── main.tf
│
├── ansible/
│   ├── inventory.ini
│   │
│   ├── playbooks/
│   │   ├── install.yml
│   │   └── deploy.yml
│   │
│   ├── group_vars/
│   │   ├── all.yml
│   │   ├── frontend.yml
│   │   └── backend.yml
│   │
│   └── handlers/
│
├── frontend/
│   ├── Dockerfile
│   └── src/
│
├── backend/
│   ├── Dockerfile
│   └── src/
│
├── .gitignore
│
└── README.md
```

---

## Ansible

* Ansible Inventory
* Ansible Installation Playbook
* Ansible Deployment Playbook
* Ansible Variables
* Ansible Handlers

---

## Application

* Dockerfile – Frontend
* Dockerfile – Backend
* Application Source Code

---

# 🧮 Grading Breakdown

| Section                                            | Points  |
| -------------------------------------------------- | ------- |
| Part 1 – AWS Network Infrastructure with Terraform | 25      |
| Part 2 – Security Groups & AWS Components          | 25      |
| Part 3 – EFS & Application Deployment              | 25      |
| Part 4 – Ansible Automation                        | 25      |
| **Total**                                          | **100** |

---

# ⚠️ Important Technical Requirements

## ☁️ Terraform

* All AWS infrastructure must be created using Terraform
* Do not manually create AWS resources through the AWS Console
* Use Terraform Outputs
* Use Terraform State correctly
* Do not commit Terraform State to Git

---

## 🌐 Networking

* Create 4 Subnets
* 2 Public Subnets
* 2 Private Subnets
* Configure Internet Gateway
* Configure NAT Gateway
* Configure Route Tables
* Use at least 2 Availability Zones

---

## 🔐 Security

* Use Security Groups
* Follow the principle of least privilege
* Backend must remain in Private Subnets
* Do not expose Backend EC2 instances directly to the internet
* Use IAM Roles instead of static AWS credentials

---

## 🐳 Docker

* Build Docker images for the application
* Store images in Amazon ECR
* Run containers on EC2 instances
* Manage Docker using Ansible

---

## ⚙️ Ansible

* Use an Ansible Master
* Use Inventory files
* Use Variables
* Use Playbooks
* Use Handlers
* Use Notify
* Avoid task duplication
* Automate installation and deployment

---

## 🗄️ Storage

* Use Amazon EFS
* Create EFS using Terraform
* Create EFS Mount Targets using Terraform
* Mount EFS on Backend EC2 instances
* Ensure data is persistent and shared where required

---

# 💡 Expected Skills

This project simulates a real-world AWS DevOps environment including:

* AWS Networking
* VPC Architecture
* Public & Private Subnets
* Internet Gateway
* NAT Gateway
* Application Load Balancer
* Target Groups
* EC2
* EFS
* Amazon ECR
* IAM Roles
* Terraform Infrastructure as Code
* Ansible Configuration Management
* Docker
* Application Deployment
* Security Best Practices