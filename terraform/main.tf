# terraform init
# terraform validate
# terraform plan
# terraform apply (plan & apply)
# terraform destroy (destroy the resources)

# terraform state list


###  AWS provider  #######################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
}

###  Virtual Private Cloud (VPC)  ########################################

resource "aws_vpc" "vpc_param" {
  cidr_block       = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc_terraform"
  }
}

###  Subnets  ############################################################

resource "aws_subnet" "public-snet-param-1a" {
  vpc_id     = aws_vpc.vpc_param.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-snet-terraform-1a"
  }

  depends_on = [aws_vpc.vpc_param]

}

resource "aws_subnet" "public-snet-param-1b" {
  vpc_id     = aws_vpc.vpc_param.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "public-snet-terraform-1b"
  }

  depends_on = [aws_vpc.vpc_param]
}

### Private subnets

resource "aws_subnet" "private-snet-param-1a" {
  vpc_id     = aws_vpc.vpc_param.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-snet-terraform-1a"
  }

  depends_on = [aws_vpc.vpc_param]
}

resource "aws_subnet" "private-snet-param-1b" {
  vpc_id     = aws_vpc.vpc_param.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-snet-terraform-1b"
  }

  depends_on = [aws_vpc.vpc_param]
}

### Internet Gateway  ###############################################

resource "aws_internet_gateway" "igw_param" {
  vpc_id = aws_vpc.vpc_param.id

  tags = {
    Name = "igw_terraform"
  }
    
  depends_on = [aws_vpc.vpc_param]
}

### Elastic IP ######################################################

locals {
  public_subnets = {
    "1a" = aws_subnet.public-snet-param-1a.id
    "1b" = aws_subnet.public-snet-param-1b.id
  }
  private_subnets = {
    "1a" = aws_subnet.private-snet-param-1a.id
    "1b" = aws_subnet.private-snet-param-1b.id
  }
}

resource "aws_eip" "eip_param" {
  for_each = local.public_subnets
  domain   = "vpc"   # This specifies that the EIP is for use in VPC (required for modern AWS)

  tags = {
    Name = "eip-terraform-${each.key}"
  }

  # Ensure the Internet Gateway exists before allocating
  depends_on = [aws_internet_gateway.igw_param] 
}

### NAT Gateway #####################################################

resource "aws_nat_gateway" "ngw_param" {
  for_each      = local.public_subnets
  allocation_id = aws_eip.eip_param[each.key].id
  subnet_id     = each.value

  tags = {
    Name = "ngw-terraform-${each.key}"
  }
  
  # Ensure the Internet Gateway exists before allocating
  depends_on = [aws_internet_gateway.igw_param]
}

### Route Tables #####################################################
# 2 public subnet -> igw
resource "aws_route_table" "public-rt-param" {
  for_each = local.public_subnets
  vpc_id = aws_vpc.vpc_param.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_param.id
  }

  tags = {
    Name = "public-rt-terraform-${each.key}"
  }
}

resource "aws_route_table_association" "public-rt-associat-param" {
  for_each = local.public_subnets
  subnet_id      = each.value
  route_table_id = aws_route_table.public-rt-param[each.key].id
}
# 2 private subnet -> 2 ngw
resource "aws_route_table" "private-rt-param" {
  for_each = local.private_subnets
  vpc_id = aws_vpc.vpc_param.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw_param[each.key].id
  }

  tags = {
    Name = "private-rt-terraform-${each.key}"
  }
}
resource "aws_route_table_association" "private-rt-associat-param" {
  for_each = local.private_subnets
  subnet_id      = each.value
  route_table_id = aws_route_table.private-rt-param[each.key].id
}

### Security Groups  #####################################################

resource "aws_security_group" "frontend-sg-param" {
  name        = "frontend-sg-terraform"
  vpc_id      = aws_vpc.vpc_param.id

  tags = {
    Name = "frontend-sg-terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "frontend-sg-ingress-param-8080" {
  security_group_id = aws_security_group.frontend-sg-param.id
  cidr_ipv4         = aws_vpc.vpc_param.cidr_block
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}
resource "aws_vpc_security_group_ingress_rule" "frontend-sg-ingress-ssh" {
  security_group_id = aws_security_group.frontend-sg-param.id
  cidr_ipv4         = "0.0.0.0/0"   # или свой IP для безопасности: "YOUR_IP/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_egress_rule" "frontend-sg-egress-param-all" {
  security_group_id = aws_security_group.frontend-sg-param.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"           # semantically equivalent to all ports
}

### Create Key Pair Name #################################################

# Create the key pair
resource "tls_private_key" "deployer" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair
resource "aws_key_pair" "deployer" {
  key_name   = "aws-ssh-key"
  public_key = tls_private_key.deployer.public_key_openssh
}

# Save the private key to file
resource "local_file" "private_key" {
  content  = tls_private_key.deployer.private_key_pem
  filename = "./aws-ssh-key.pem"
  file_permission = "0400"
}

# Output the key pair name (optional)
output "key_pair_name" {
  value = aws_key_pair.deployer.key_name
}

### EC2  ###################################################################################

data "aws_ssm_parameter" "ubuntu" {
  name = "/aws/service/canonical/ubuntu/server/26.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

resource "aws_instance" "ec2-frontend-param" {
    for_each = local.public_subnets
    ami = data.aws_ssm_parameter.ubuntu.value
    instance_type = "t3.micro"
    subnet_id = each.value
    vpc_security_group_ids = [aws_security_group.frontend-sg-param.id]   # otherwise all traffic is blocked
    key_name = aws_key_pair.deployer.key_name                            # otherwise you can't access it via SSH
    associate_public_ip_address = true                                   # if this is a public subnet and external access is required

    tags = {
        Name = "ec2-terraform-frontend-${each.key}"
    }
}

