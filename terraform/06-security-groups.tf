# SG + ingress/egress rules


### backend Security Group ########################################################
resource "aws_security_group" "backend-sg-param" {
  name        = "backend-sg-terraform"
  vpc_id      = aws_vpc.vpc_param.id

  tags = {
    Name = "backend-sg-terraform"
  }
}

### ingress/egress rules #############

resource "aws_vpc_security_group_ingress_rule" "backend-sg-ingress-param-8080" {
  security_group_id = aws_security_group.backend-sg-param.id
  cidr_ipv4         = aws_vpc.vpc_param.cidr_block
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

resource "aws_vpc_security_group_ingress_rule" "backend-sg-ingress-ssh" {
  security_group_id = aws_security_group.backend-sg-param.id
  cidr_ipv4         = "0.0.0.0/0"   # "YOUR_IP/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "backend-sg-egress-param-all" {
  security_group_id = aws_security_group.backend-sg-param.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"           # semantically equivalent to all ports
}

### frontend Security Group #######################################################

resource "aws_security_group" "frontend-sg-param" {
  name        = "frontend-sg-terraform"
  vpc_id      = aws_vpc.vpc_param.id

  tags = {
    Name = "frontend-sg-terraform"
  }
}

### ingress/egress rules  ################

resource "aws_vpc_security_group_ingress_rule" "frontend-sg-ingress-param-8080" {
  security_group_id = aws_security_group.frontend-sg-param.id
  cidr_ipv4         = aws_vpc.vpc_param.cidr_block
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

resource "aws_vpc_security_group_ingress_rule" "frontend-sg-ingress-ssh" {
  security_group_id = aws_security_group.frontend-sg-param.id
  cidr_ipv4         = "0.0.0.0/0"   # "YOUR_IP/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "frontend-sg-egress-param-all" {
  security_group_id = aws_security_group.frontend-sg-param.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"           # semantically equivalent to all ports
}
