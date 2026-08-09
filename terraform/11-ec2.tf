# data "aws_ssm_parameter" + aws_instance


### AWS Systems Manager Parameter Store #####################################################################
# Canonical's public SSM parameter - always points to the current AMI ID
# for Ubuntu 26.04 LTS (updated automatically with patches, without hardcoding the AMI ID)

data "aws_ssm_parameter" "ubuntu" {
  name = "/aws/service/canonical/ubuntu/server/26.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

### EC2 instances ###########################################################################################

# 1 - frontend

resource "aws_instance" "ec2-frontend-param" {
    ami = data.aws_ssm_parameter.ubuntu.value
    instance_type = "t3.micro"
    subnet_id = aws_subnet.public-snet-param-1a.id
    vpc_security_group_ids = [aws_security_group.frontend-sg-param.id]   
    key_name = aws_key_pair.deployer.key_name                            # otherwise you can't access it via SSH
    associate_public_ip_address = true                                   # if this is a public subnet and external access is required

    tags = {
        Name = "ec2-terraform-frontend-1a"
    }
}

2 - backend

resource "aws_instance" "ec2-backend-param" {
    for_each = local.private_subnets
    ami = data.aws_ssm_parameter.ubuntu.value
    instance_type = "t3.micro"
    subnet_id = each.value
    vpc_security_group_ids = [aws_security_group.backend-sg-param.id]   
    key_name = aws_key_pair.deployer.key_name                            
    associate_public_ip_address = false                                  

    tags = {
        Name = "ec2-terraform-backend-${each.key}"
    }
}