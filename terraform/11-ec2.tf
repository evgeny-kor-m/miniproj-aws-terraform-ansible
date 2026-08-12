# data "aws_ssm_parameter" + aws_instance


### AWS Systems Manager Parameter Store #####################################################################
# Canonical's public SSM parameter - always points to the current AMI ID
# for Ubuntu 26.04 LTS (updated automatically with patches, without hardcoding the AMI ID)

# data source, it can only read an existing parameter from AWS
data "aws_ssm_parameter" "ubuntu" {
  name = "/aws/service/canonical/ubuntu/server/26.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

### EC2 instances ###########################################################################################

### 1 - frontend EC2 instances in the public subnets

resource "aws_instance" "ec2-frontend-param" {
  ami                         = data.aws_ssm_parameter.ubuntu.value
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public-snet-param-1a.id
  vpc_security_group_ids      = [aws_security_group.frontend-sg-param.id]
  key_name                    = aws_key_pair.deployer.key_name # otherwise you can't access it via SSH by ubuntu user
  associate_public_ip_address = true                           # if this is a public subnet and external access is required
  iam_instance_profile        = aws_iam_instance_profile.ec2-profile-param.name

  user_data = <<-EOF
    #!/bin/bash

    useradd -m -s /bin/bash ansible
    usermod -aG sudo ansible
    mkdir -p /home/ansible/.ssh
    echo "${tls_private_key.deployer.public_key_openssh}" > /home/ansible/.ssh/authorized_keys
    chown -R ansible:ansible /home/ansible/.ssh
    chmod 700 /home/ansible/.ssh
    chmod 600 /home/ansible/.ssh/authorized_keys
    echo "ansible ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
  EOF

  tags = {
    Name        = "ec2-frontend-tf-1a"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

### 2 - backend EC2 instances in the private subnets

resource "aws_instance" "ec2-backend-param" {
  for_each                    = local.private_subnets
  ami                         = data.aws_ssm_parameter.ubuntu.value
  instance_type               = "t3.micro"
  subnet_id                   = each.value
  vpc_security_group_ids      = [aws_security_group.backend-sg-param.id]
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2-profile-param.name

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nfs-common

    mkdir -p /mnt/efs
    mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs-param.id}.efs.us-east-1.amazonaws.com:/ /mnt/efs

    echo "${aws_efs_file_system.efs-param.id}.efs.us-east-1.amazonaws.com:/ /mnt/efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab

    chown ubuntu:ubuntu /mnt/efs
    chmod 775 /mnt/efs

    useradd -m -s /bin/bash ansible
    usermod -aG sudo ansible
    mkdir -p /home/ansible/.ssh
    echo "${tls_private_key.deployer.public_key_openssh}" > /home/ansible/.ssh/authorized_keys
    chown -R ansible:ansible /home/ansible/.ssh
    chmod 700 /home/ansible/.ssh
    chmod 600 /home/ansible/.ssh/authorized_keys
    # echo PubkeyAuthentication yes >> /etc/ssh/sshd_config
    # echo PasswordAuthentication yes >> /etc/ssh/sshd_config
    # echo "ansible:ansible" | chpasswd
    echo "ansible ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
  EOF

  tags = {
    Name        = "ec2-backend-tf-${each.key}"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }

  depends_on = [aws_efs_mount_target.efs-mount-target-param]
}

### 1 - Ansible Master EC2 Instance in the public subnets

resource "aws_instance" "ec2-ansible-param" {
  ami                         = data.aws_ssm_parameter.ubuntu.value
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public-snet-param-1b.id
  vpc_security_group_ids      = [aws_security_group.ansible-sg-param.id]
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ansible-profile-param.name # privet key 

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y ansible

    mkdir -p /home/ubuntu/.ssh
    echo "${aws_ssm_parameter.ansible_private_key.value}" > /home/ubuntu/.ssh/aws-ssh-key.pem
    chown -R ubuntu:ubuntu /home/ubuntu/.ssh
    chmod 700 /home/ubuntu/.ssh
    chmod 600 /home/ubuntu/.ssh/aws-ssh-key.pem 
  EOF

  tags = {
    Name        = "ec2-ansible-tf-1b"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}
