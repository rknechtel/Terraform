## apim\preprod\backend.tf
### Declare Terraform Provider ###
### Note: Declaring versions in "provider" block is depricated" ###
### Terraform Version is declared in .devcontainer.json ###
provider "azurerm" {
  # Note: Must upgrade versions incrementally - big jumps in versions causes issues in APIM.
  #version = "2.37.0" # Works ok.
  #version = "2.38.0" # Works ok.
  #version = "2.39.0" # Works ok.
  #version = "2.40.0" # Works ok.
  #version = "2.41.0" # Works ok.
  #version = "2.42.0" # Works ok.
  #version = "2.43.0" # Works ok.
  #version = "2.44.0" # Works ok.
  #version = "2.45.0" # Works ok.
  #version = "2.46.0" # Works ok.
  #version = "2.47.0" # Works ok.
  features {}
}

terraform {

    backend "azurerm" {
        container_name          = "apimstatebackend"
        use_msi = true
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
      # Upgrading to Terraform v0.14.6 - Terraform by HashiCorp
      # https://www.terraform.io/upgrade-guides/0-14.html
      source  = "hashicorp/azurerm"
      # Note: Must upgrade versions incrementally - big jumps in versions causes issues in APIM.
      #version = "2.37.0" # Works ok.
      #version = "2.38.0" # Works ok.
      #version = "2.39.0" # Works ok.
      #version = "2.40.0" # Works ok.
      #version = "2.41.0" # Works ok.
      #version = "2.42.0" # Works ok.
      #version = "2.43.0" # Works ok.
      #version = "2.44.0" # Works ok.
      #version = "2.45.0" # Works ok.
      #version = "2.46.0" # Works ok.
      version = "2.47.0" # Works ok.
    }
  }
}