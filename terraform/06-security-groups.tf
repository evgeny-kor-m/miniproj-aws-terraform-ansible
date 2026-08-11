# SG + ingress/egress rules


### Backend Security Group ########################################################
resource "aws_security_group" "backend-sg-param" {
  name   = "backend-sg-tf"
  vpc_id = aws_vpc.vpc_param.id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "backend-sg-tf"
  }
}

### ingress/egress rules #######

resource "aws_vpc_security_group_ingress_rule" "backend-sg-ingress-param-8080" {
  security_group_id            = aws_security_group.backend-sg-param.id
  referenced_security_group_id = aws_security_group.alb-sg-param.id # allow trafic from ALB application through security group
  from_port                    = 8080
  ip_protocol                  = "tcp"
  to_port                      = 8080
}

resource "aws_vpc_security_group_ingress_rule" "backend-sg-ingress-ssh" {
  security_group_id = aws_security_group.backend-sg-param.id
  cidr_ipv4         = "0.0.0.0/0" # "YOUR_IP/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "backend-sg-egress-param-all" {
  security_group_id = aws_security_group.backend-sg-param.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

### Frontend Security Group #######################################################

resource "aws_security_group" "frontend-sg-param" {
  name   = "frontend-sg-tf"
  vpc_id = aws_vpc.vpc_param.id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "frontend-sg-tf"
  }
}

### ingress/egress rules  ######

resource "aws_vpc_security_group_ingress_rule" "frontend-sg-ingress-param-3000" {
  security_group_id = aws_security_group.frontend-sg-param.id
  cidr_ipv4         = aws_vpc.vpc_param.cidr_block
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 3000
}

resource "aws_vpc_security_group_ingress_rule" "frontend-sg-ingress-ssh" {
  security_group_id = aws_security_group.frontend-sg-param.id
  cidr_ipv4         = "0.0.0.0/0" # "172.26.15.255/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "frontend-sg-egress-param-all" {
  security_group_id = aws_security_group.frontend-sg-param.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

### ALB Security Group #######################################################

resource "aws_security_group" "alb-sg-param" {
  name   = "alb-sg-tf"
  vpc_id = aws_vpc.vpc_param.id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "alb-sg-tf"
  }
}

### ingress/egress rules  ######

### Ansible Master Security Group #######################################################

resource "aws_security_group" "ansible-sg-param" {
  name   = "ansible-sg-tf"
  vpc_id = aws_vpc.vpc_param.id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "ansible-sg-tf"
  }
}

### ingress/egress rules  ######

resource "aws_vpc_security_group_ingress_rule" "ansible-sg-ingress-ssh" {
  security_group_id = aws_security_group.ansible-sg-param.id
  cidr_ipv4         = "0.0.0.0/0" # "172.26.15.255/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "ansible-sg-egress-param-all" {
  security_group_id = aws_security_group.ansible-sg-param.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

### EFS Security Group ########################################################
resource "aws_security_group" "efs-sg-param" {
  name   = "efs-sg-tf"
  vpc_id = aws_vpc.vpc_param.id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "efs-sg-tf"
  }
}

### ingress/egress rules #######

resource "aws_vpc_security_group_ingress_rule" "efs-sg-ingress-param-2049" {
  security_group_id            = aws_security_group.efs-sg-param.id
  referenced_security_group_id = aws_security_group.backend-sg-param.id # allow trafic from Backend application through security group
  from_port                    = 2049
  ip_protocol                  = "tcp"
  to_port                      = 2049
}

resource "aws_vpc_security_group_egress_rule" "efs-sg-egress-param-all" {
  security_group_id = aws_security_group.efs-sg-param.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
