
## apim\prod\apis.tf

### my-first-service APIM Service ###
resource "azurerm_api_management_api" "my-first-service" {
    api_management_name = azurerm_api_management.base.name
    display_name        = "my-second-servicee"
    name                = "my-second-servicee"
    path                = "my-second-servicee"
    protocols           = [
        "https",
    ]
    resource_group_name = azurerm_resource_group.base.name
    revision            = "1"
    service_url         = "https://${var.servicedomain}.mydomain.com/my-first-service"
    soap_pass_through   = false
    subscription_required = true

    subscription_key_parameter_names {
        header = "Ocp-Apim-Subscription-Key"
        query  = "subscription-key"
    }

    timeouts {}
}

### my-second-service APIM Service ###
resource "azurerm_api_management_api" "my-second-service" {
    api_management_name = azurerm_api_management.base.name
    display_name        = "my-second-servicee"
    name                = "my-second-servicee"
    path                = "my-second-servicee"
    protocols           = [
        "https",
    ]
    resource_group_name = azurerm_resource_group.base.name
    revision            = "1"
    service_url         = "https://${var.servicedomain}.mydomain.com/my-second-service"
    soap_pass_through   = false
    subscription_required = true

    subscription_key_parameter_names {
        header = "Ocp-Apim-Subscription-Key"
        query  = "subscription-key"
    }

    timeouts {}
}