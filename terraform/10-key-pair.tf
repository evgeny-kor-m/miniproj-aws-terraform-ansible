# tls_private_key + aws_key_pair + local_file

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

