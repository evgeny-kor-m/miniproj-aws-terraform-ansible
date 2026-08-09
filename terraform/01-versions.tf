# terraform {} block + required_providers

### Commands ##########################################################

# terraform init
# terraform validate
# terraform plan
# terraform apply (plan & apply)
# terraform destroy (destroy the resources)
# terraform state list


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
  }
}
