## apim\backend.tf

terraform {
    backend "azurerm" {
        container_name = "apimstatebackend"
    }
}