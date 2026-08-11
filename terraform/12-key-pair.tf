# tls_private_key + aws_key_pair + local_file + SSM SecureString

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
  content         = tls_private_key.deployer.private_key_pem
  filename        = "./aws-ssh-key.pem"
  file_permission = "0400"
}

### SSM Parameter — Ansible deployer private key ##########################
# Stores the private SSH key as a SecureString (encrypted at rest via KMS)
# so the Ansible Master can fetch it at boot time without hardcoding the
# key in plaintext user_data. Access is restricted via IAM to instances
# using the ansible-role-param role only.
resource "aws_ssm_parameter" "ansible_private_key" {
  name  = "/ansible/deployer-key"
  type  = "SecureString"
  value = tls_private_key.deployer.private_key_pem

  tags = {
    Name = "ansible-deployer-key-tf"
  }
}
