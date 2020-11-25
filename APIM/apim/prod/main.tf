
## apim\main.tf

### Declare Terraform Provider and Version ###
### Terraform Version is declared in .devcontainer.json ###
provider "azurerm" {
  version = "=2.37.0"
  use_msi = true

  features {}
}

locals {
  prefix = "${var.baseprefix}-${var.envshort}-${var.service}-${var.envshort}-"
  suffix = "-${var.locshort}-${var.baseindex}"
  prd = var.environment == "prd"
}

resource "azurerm_resource_group" "base" {
  name     = "${local.prefix}rg${local.suffix}"
  location = var.location
}

### APIM Subnet 112.15.157.0/24 ###
resource "azurerm_subnet" "base" {
  name                 = "${var.baseprefix}-${var.envshort}-${var.service}-sn${local.suffix}"
  resource_group_name  = local.prd ? var.prdoverride : "${var.baseprefix}-${var.envshort}-network-${var.envshort}-rg-prod${local.suffix}"
  virtual_network_name = "${var.baseprefix}-${var.envshort}-vnet-${var.environment}${local.suffix}"
  address_prefix       = var.subnetprefix
 }

 ### NSG FOR APIM ###
resource "azurerm_network_security_group" "base" {
  name                = "${var.baseprefix}-${var.envshort}-nsg-${var.environment}-${var.locshort}-0147"
  location            = var.location
  resource_group_name = "${var.baseprefix}-${var.envshort}-nsg-${var.envshort}-rg-cus-0001"
}

### Create APIM ###
resource "azurerm_api_management" "base" {
  name                 = "${var.environment}-mycompany-${var.service}"
  location             = var.location
  resource_group_name  = azurerm_resource_group.base.name
  publisher_name       = "My Company"
  publisher_email      = "me@mycompany.com"
  sku_name             = var.apimsku
  virtual_network_type = "External"

  identity {
    type = "SystemAssigned"
  }
  
  virtual_network_configuration {
    subnet_id = azurerm_subnet.base.id
  }

  ### Create Custom Domain ###
  ### Note: key_vault_id - URL Comes from: ### 
  ###  Key vaults --> KEYVAULT --> Settings --> Certificates --> SSLCERTIFICATEINKEYVAULT --> Completed --> CURRENT VERSION --> Properties --> Secret Identifier ###
  ### Note: Custom Domain should show up in APIM: ###
  ### APIMINSTNACE --> Deployment and infrastructure --> Custom domains ###  
  resource "azurerm_api_management_custom_domain" "preprod" {
    api_management_id = azurerm_api_management.base.id

    proxy {
      host_name    = var.customdomain
      key_vault_id = var.keyvaultsecretid
    }

    depends_on = [azurerm_api_management.base]
  }

}

### Create AAD Identity Provider ###
resource "azurerm_api_management_identity_provider_aad" "base" {
  api_management_name = azurerm_api_management.base.name
  resource_group_name = azurerm_resource_group.base.name
  client_id           = var.aadid
  client_secret       = var.aadsec
  allowed_tenants     = [var.aadten]
}
