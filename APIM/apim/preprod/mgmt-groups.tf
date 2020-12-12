
## apim\preprod\mgmt-groups.tf

### APIM Management Group cmicdevelopers ###
resource "azurerm_api_management_group" "mydevelopers" {
  name                = "mydevelopers"
  resource_group_name = azurerm_resource_group.base.name
  api_management_name = azurerm_api_management.base.name
  display_name        = "MyDevelopers"
  description         = "Group for Internal Developers"
}