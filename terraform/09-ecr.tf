# ECR repo + policies

### Frontend ECR Repository #############################################

resource "aws_ecr_repository" "frontend-img-param" {
  name                 = "frontend-img-tf"
  image_tag_mutability = "MUTABLE"       # MUTABLE, IMMUTABLE, IMMUTABLE_WITH_EXCLUSION, or MUTABLE_WITH_EXCLUSION

  image_scanning_configuration {
    scan_on_push = true                  # Automatically scans images for vulnerabilities
  }

  encryption_configuration {
    encryption_type = "AES256"           # Encrypts your images at rest
  }

  tags = {
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

### Backend ECR Repository ###############################################

resource "aws_ecr_repository" "backend-img-param" {
  name                 = "backend-img-tf"
  image_tag_mutability = "MUTABLE"       

  image_scanning_configuration {
    scan_on_push = true                  
  }

  encryption_configuration {
    encryption_type = "AES256"           
  }

  tags = {
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

### Frontend Lifecycle Policy #############################################

resource "aws_ecr_lifecycle_policy" "frontend-lifecycle" {
  repository = aws_ecr_repository.frontend-img-param.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove untagged images older than 5 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep only the last 5 tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v", "latest"]   # applies only to images with these tag prefixes
          countType     = "imageCountMoreThan"
          countNumber   = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

### Backend Lifecycle Policy ###############################################

resource "aws_ecr_lifecycle_policy" "backend-lifecycle" {
  repository = aws_ecr_repository.backend-img-param.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove untagged images older than 5 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep only the last 5 tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v", "latest"]   # applies only to images with these tag prefixes
          countType     = "imageCountMoreThan"
          countNumber   = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}