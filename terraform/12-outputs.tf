# all output {} blocks

### Output the key pair name (optional) #############################
output "key_pair_name" {
  value = aws_key_pair.deployer.key_name
}