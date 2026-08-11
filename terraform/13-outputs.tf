# all output {} blocks

### Output the key pair name (optional) #############################

output "key_pair_name" {
  value       = aws_key_pair.deployer.key_name
  description = "Name of the SSH key pair used for EC2 access"
}

output "elb-dns-name" {
  value       = aws_lb.alb-param.dns_name
  description = "DNS name of the Application Load Balancer"
}

# Output the repository URLs so you can use them in your Docker push commands

output "frontend_repository_url" {
  value       = aws_ecr_repository.frontend-img-param.repository_url
  description = "The URL of the frontend ECR repository"
}

output "backend_repository_url" {
  value       = aws_ecr_repository.backend-img-param.repository_url
  description = "The URL of the backend ECR repository"
}

# EFS

output "efs_id" {
  value       = aws_efs_file_system.efs-param.id
  description = "EFS file system ID"
}

output "efs_dns_name" {
  value       = aws_efs_file_system.efs-param.dns_name
  description = "EFS DNS name for mounting"
}

# output "access_point_ids" {
#   value       = aws_efs_access_point.efs-access-point-param.id
#   description = "Access point IDs by service"
# }
