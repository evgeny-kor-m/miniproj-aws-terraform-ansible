# terraform {} block + required_providers

### Commands ##########################################################

# terraform init
# terraform validate
# terraform plan
# terraform apply (plan & apply)
# terraform destroy (destroy the resources)
# terraform providers
# terraform state list

# - remove resource from state
# terraform state rm aws_ecr_repository.frontend-img-param
# terraform state list

# -  recreate instance
# terraform taint 'aws_instance.ec2-backend-param["1b"]'  
# terraform apply                                         

# - "-target" is a , flag that forces Terraform to apply changes only to the specified resource (and its dependencies), ignoring everything else in the configuration.
# terraform apply -target=aws_instance.ec2-frontend-param 


###  Providers  #######################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}
