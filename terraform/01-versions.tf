# terraform {} block + required_providers

### Commands ##########################################################

# terraform init
# terraform validate
# terraform plan
# terraform apply (plan & apply)
# terraform destroy (destroy the resources)
# terraform state list
# terraform providers
# terraform taint 'aws_instance.ec2-backend-param["1b"]'  -  recreate instance

# terraform apply -target=aws_instance.ec2-frontend-param 
#   "-target" - is a flag that forces Terraform to apply changes only to the specified resource (and its dependencies), 
#   ignoring everything else in the configuration, even if there are planned changes there too.

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
