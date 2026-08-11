# IAM Roles + Policies + Instance Profiles

### Trust Policy (who can take on the role) ################################

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]   # the role is intended for the EC2 service
    }
  }
}

### IAM ECR Role ##########################################################

resource "aws_iam_role" "ec2-ecr-role-param" {
  name               = "ec2-ecr-role-tf"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Name = "ec2-ecr-role-tf"
  }
}

### IAM Policy Attachment #########

resource "aws_iam_role_policy_attachment" "ecr-readonly-param" {
  role       = aws_iam_role.ec2-ecr-role-param.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

### Instance Profile ##############

resource "aws_iam_instance_profile" "ec2-profile-param" {
  name = "ec2-ecr-profile-tf"
  role = aws_iam_role.ec2-ecr-role-param.name
}

### Ansible Role (SSM key access) #########################################

# For the Ansible Master only — grants read access to the SSM deployer key parameter.
resource "aws_iam_role" "ansible-role-param" {
  name               = "ansible-role-tf"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Name = "ansible-role-tf"
  }
}

data "aws_iam_policy_document" "ssm_read_key" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameter"]
    resources = [aws_ssm_parameter.ansible_private_key.arn]
  }
}

resource "aws_iam_role_policy" "ssm-read-key-param" {
  name   = "ssm-read-ansible-key"
  role   = aws_iam_role.ansible-role-param.id
  policy = data.aws_iam_policy_document.ssm_read_key.json
}

resource "aws_iam_instance_profile" "ansible-profile-param" {
  name = "ansible-profile-tf"
  role = aws_iam_role.ansible-role-param.name
}