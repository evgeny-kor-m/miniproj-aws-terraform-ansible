# VPC + subnets (public/private)

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

### Public subnets

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

### locals #########################################################

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