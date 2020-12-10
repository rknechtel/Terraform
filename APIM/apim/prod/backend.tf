## apim\backend.tf

### Declare Terraform Provider and Version ### ### Terraform Version is declared in .devcontainer.json ### 
provider "azurerm" {
  version = "=2.37.0"
  features {}
}

provider "null" {
  version = "=3.0.0"
}

terraform {

    backend "azurerm" {
        container_name          = "apimstatebackend"
    }

  ### Declare Terraform Provider and Version ###
  ### Terraform Version is declared in .devcontainer.json ###
  required_providers {
    azurerm = {
      # The "hashicorp" namespace is the new home for the HashiCorp-maintained
      # provider plugins.
      #
      # Source is not required for the hashicorp/* namespace 
      # as a measure of backward compatibility for commonly-used providers, 
      # but recommended for explicitness.
      # Ref:
      # Upgrading to Terraform v0.13 - Terraform by HashiCorp
      # https://www.terraform.io/upgrade-guides/0-13.html
      source  = "hashicorp/azurerm"
      version = "2.37.0"
      use_msi = true

    }

    ### Use for null_resource ###
    null = {
      source  = "hashicorp/null"
      version = "3.0.0"
      use_msi = true
    }

  }
}