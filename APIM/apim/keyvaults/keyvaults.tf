
### File: keyvaults/keyvaults.tf ###
### RSK 10/19/2020 - Commenting out Key Vault stuff - Can't conditionally create for only preprod and prod ###
### Resource Group For APIM Key Vault ###
### Only create in Preprod and Production ###
#resource "azurerm_resource_group" "keyvault" {
#  name     = "${var.baseprefix}-${var.envshort}-APIMKeyVault-${var.envshort}-rg${local.suffix}"
#  location = var.location
#}

 

### Using this data source to access the configuration of the AzureRM provider ###
#data "azurerm_client_config" "current" {}


### APIM Key Vault ###
### Note: Created under the above keyvault APIMKeyVault Resource Group ###
### Only create in Preprod and Production ###
#resource "azurerm_key_vault" "apimkeyvault" {
#  name                        = "${var.baseprefix}-${var.envshort}-apimkeyvault"
#  location                    = azurerm_resource_group.keyvault.location
#  resource_group_name         = azurerm_resource_group.keyvault.name
#  enabled_for_disk_encryption = false
#  tenant_id                   = data.azurerm_client_config.current.tenant_id
#  soft_delete_enabled         = true
#  soft_delete_retention_days  = "90"
#  purge_protection_enabled    = false
#
#  sku_name = "standard"
#
#  access_policy {
#    tenant_id = data.azurerm_client_config.current.tenant_id
#    object_id = data.azurerm_client_config.current.object_id
#    application_id = var.adapplicationid
#
#    key_permissions = [
#      "get",
#    ]
#
#    secret_permissions = [
#      "get",
#    ]
#
#    storage_permissions = [
#      "get",
#    ]
#  }
#
#  network_acls {
#    default_action = "Allow"
#    bypass         = "AzureServices"
#  }
#
#  depends_on    = [azurerm_resource_group.keyvault]
#}
#

#resource "azurerm_key_vault_access_policy" "core_apim" {
#  key_vault_id = "${azurerm_key_vault.core.id}"
#
#  tenant_id = "${azurerm_api_management.core.identity.tenant_id}"
#  object_id = "${azurerm_api_management.core.identity.principal_id}"
#
#  key_permissions = [
#    "backup", "create", "decrypt", "delete", "encrypt", "get", "import", "list", "purge", "recover", "restore", "sign", "unwrapKey", "update", "verify", "wrapKey"
#  ]
#
#  secret_permissions = [
#    "backup", "delete", "get", "list", "purge", "recover", "restore", "set"
#  ]
#
#  certificate_permissions = [
#    "backup", "create", "delete", "deleteissuers", "get", "getissuers", "import", "list", "listissuers", "managecontacts", "manageissuers", "purge", "recover", "restore", "setissuers", "update"
#  ]
#}