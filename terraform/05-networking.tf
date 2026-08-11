# IGW + EIP + NAT + route tables + associations

### Internet Gateway  ###############################################

resource "aws_internet_gateway" "igw_param" {
  vpc_id = aws_vpc.vpc_param.id

  tags = {
    Name = "igw-tf"
  }
    
  depends_on = [aws_vpc.vpc_param]
}

### Elastic IP ######################################################

resource "aws_eip" "eip_param" {
  for_each = local.public_subnets
  domain   = "vpc"   # This specifies that the EIP is for use in VPC (required for modern AWS)

  tags = {
    Name = "eip-tf-${each.key}"
  }

  # Ensure the Internet Gateway exists before allocating
  depends_on = [aws_internet_gateway.igw_param] 
}

### NAT Gateway #####################################################

resource "aws_nat_gateway" "ngw-param" {
  for_each      = local.public_subnets
  allocation_id = aws_eip.eip_param[each.key].id
  subnet_id     = each.value

  tags = {
    Name = "ngw-tf-${each.key}"
  }
  
  # Ensure the Internet Gateway exists before allocating
  depends_on = [aws_internet_gateway.igw_param]
}

### Route Tables #####################################################

# 1 public subnet -> igw
resource "aws_route_table" "public-rt-param" {
  vpc_id = aws_vpc.vpc_param.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_param.id
  }

  tags = {
    Name = "public-rt-tf"
  }
}

# 2 private subnet -> 2 ngw
resource "aws_route_table" "private-rt-param" {
  for_each = local.private_subnets
  vpc_id = aws_vpc.vpc_param.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw-param[each.key].id
  }

  tags = {
    Name = "private-rt-tf-${each.key}"
  }
}

### Route Table Associations ###########################################

# public

resource "aws_route_table_association" "public-rt-associat-param" {
  for_each = local.public_subnets
  subnet_id      = each.value
  route_table_id = aws_route_table.public-rt-param.id
}

# private

resource "aws_route_table_association" "private-rt-associat-param" {
  for_each = local.private_subnets
  subnet_id      = each.value
  route_table_id = aws_route_table.private-rt-param[each.key].id
}