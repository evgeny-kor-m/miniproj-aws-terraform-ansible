# EFS + mount targets

### EFS File System #######################################################################

resource "aws_efs_file_system" "efs-param" {
  creation_token = "token-shared-storage"
  encrypted      = true

  performance_mode = "generalPurpose" # or "maxIO" for highly parallel workloads
  throughput_mode  = "bursting"       # or "elastic" for unpredictable workloads

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS" # Move files to Infrequent Access after 30 days
  }

  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS" # Move back on first access
  }

  tags = {
    Name        = "efs-tf"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

### Mount Targets ########################################################################
# For Regional file systems, create one mount target in each AZ where your workloads run. 
# This creates a mount target in each private subnet:

resource "aws_efs_mount_target" "efs-mount-target-param" {
  for_each        = local.private_subnets
  file_system_id  = aws_efs_file_system.efs-param.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs-sg-param.id]
}

### Access Points ########################################################################
# Access points are like virtual entry points into your file system. They let you enforce a specific POSIX user, group, and root directory for each application.

# resource "aws_efs_access_point" "efs-access-point-param" {
#   file_system_id = aws_efs_file_system.efs-param.id

#   posix_user {
#     gid = 1001
#     uid = 1001
#   }

#   root_directory {
#     path = "/data"
#     creation_info {
#       owner_gid   = 1001
#       owner_uid   = 1001
#       permissions = "755"
#     }
#   }

#   tags = {
#     Name = "efs-access-point-tf"
#   }
# }
