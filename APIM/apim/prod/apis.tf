
## apim\dev\apis.tf

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

### my-first-service API Policy ###
### This goes after API and API Operatinos Definitions ###
resource "azurerm_api_management_api_policy" "my-first-servicepolicy" {
  api_name            = azurerm_api_management_api.my-first-service.name
  api_management_name = azurerm_api_management_api.my-first-service.api_management_name
  resource_group_name = azurerm_api_management_api.my-first-service.resource_group_name

    ### APIM Policies ###
    xml_content = <<XML
    <!-- Note: this is to restrict what IP's Can call this API -->
    <policies>
      <inbound>
        <ip-filter action="allow">
          <address>106.238.170.45</address>
          <address>106.238.171.50</address>
          <address>106.238.172.55</address>
        </ip-filter>
      </inbound>
    </policies>
    XML

  depends_on    = [azurerm_api_management_api.my-first-service]
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
