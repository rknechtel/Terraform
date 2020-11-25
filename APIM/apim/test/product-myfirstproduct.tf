
# apim\product-myfirstproduct.tf

### Base product definition ###

### Create myfirstproduct APIM Product ###
resource "azurerm_api_management_product" "intdevs" {
  product_id            = "myfirstproduct"
  api_management_name   = azurerm_api_management.base.name
  resource_group_name   = azurerm_resource_group.base.name
  display_name          = "myfirstproduct"
  description           = "Used for Internal Developers"
  subscription_required = "true"
  approval_required     = "false"
  published             = "true"
}

### Access control group ###

### myfirstproduct Product Access Control Group mydevelopers ###
resource "azurerm_api_management_product_group" "mydevelopers" {
  product_id          = azurerm_api_management_product.mydevelopers.product_id
  group_name          = azurerm_api_management_group.mydevelopers.name
  api_management_name = azurerm_api_management.base.name
  resource_group_name = azurerm_resource_group.base.name
}

### API assignments ###

### Add my-first-service to myfirstproduct Product ###
resource "azurerm_api_management_product_api" "my-first-servicemyfirstproduct" {
  resource_group_name = azurerm_resource_group.base.name
  api_management_name = azurerm_api_management.base.name
  product_id          = azurerm_api_management_product.mydevelopers.product_id
  api_name            = "my-first-service"
} 
 
 ### Add my-second-servicee to myfirstproduct Product ###
resource "azurerm_api_management_product_api" "my-second-serviceemyfirstproduct" {
  resource_group_name = azurerm_resource_group.base.name
  api_management_name = azurerm_api_management.base.name
  product_id          = azurerm_api_management_product.mydevelopers.product_id
  api_name            = "my-second-servicee"
}