## apim\prod\main.tf

locals {
  prefix = "${var.baseprefix}-${var.envshort}-${var.service}-${var.envshort}-"
  suffix = "-${var.locshort}-${var.baseindex}"
  useoverride = var.environment == "prd" || var.environment == "preprod"
  standard_tags_7777 = {    
    CostCenter   = "7777"
    Department   = "IT"
    Environment  = "upper(var.environment)"
    Terraform    = "Yes"
  }
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

### Add a Production User Assigned Identity ###
### Note: Created under the above Base APIM Resource Group ###
### Gets put in: APIM --> Security --> Managed identities --> User assigned ###
resource "azurerm_user_assigned_identity" "prspImportRootCA" {
  resource_group_name = azurerm_resource_group.base.name
  location            = var.location
  name = var.userassignedidentity

  depends_on = [azurerm_resource_group.base]
}

### Create APIM ###
### Note: Created under the above Base APIM Resource Group ###
### Note: RSK 10/09/2020: Added on-error policy to capture better error messages ###
resource "azurerm_api_management" "base" {
  name                 = "${var.environment}-mycompany-${var.service}"
  location             = var.location
  resource_group_name  = azurerm_resource_group.base.name
  publisher_name       = "My Company"
  publisher_email      = "me@mycompany.com"
  sku_name             = var.apimsku
  virtual_network_type = "External"

  # Link new User Assigned Identity to APIM
  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [
        azurerm_user_assigned_identity.prspImportRootCA.id
    ] 
  }

### Note Added "Default" stuff here ###
  hostname_configuration {
    proxy {
      default_ssl_binding          = true
      host_name                    = "${var.environment}-mycompany-${var.service}.azure-api.net"
      negotiate_client_certificate = false
    }
    
    ### Create Preprod Custom Domain and link to SSL Certificate in Key Vault ###
    proxy {
      default_ssl_binding = true
      host_name    = var.customdomain
      key_vault_id = var.keyvaultsecretid
      negotiate_client_certificate = false
    }    
  }

  protocols {
    enable_http2 = false
  }

  security {
    enable_backend_ssl30      = false
    enable_backend_tls10      = false
    enable_backend_tls11      = false
    enable_frontend_ssl30     = false
    enable_frontend_tls10     = false
    enable_frontend_tls11     = false
    enable_triple_des_ciphers = false
  }

  sign_in {
    enabled = false
  }

  sign_up {
    enabled = true

    terms_of_service {
      consent_required = false
      enabled          = false
    }
  }

  timeouts {}

  ### Virtual Network Configuration ###
  virtual_network_configuration {
    subnet_id = azurerm_subnet.base.id
  }


  ### Upload Root CA Cert into APIM ###
  ### Rich Note: This doesn't create cert under "Security" --> "CA Certificates" Like it needs to be
  ###            It puts it under "Security" --> "Certificates"
  ###            Manually upload after each Terraform run in each environment
#  certificate {
#    encoded_certificate = filebase64("sslcerts/DOMAINRootCA1.cer")
#    encoded_certificate = filebase64("sslcerts/DOMAINRootCA.pfx")
#    certificate_password = "PASSWORD"
#    store_name = "Root"
#  }

#  hostname_configuration {
#    proxy {
#      host_name = "${var.environment}-apim-mycopany-com"
#      key_vault_id = "${data.azurerm_key_vault_secret.core_apim.id}"
#    }s is there one 
#  }

  ### APIM Policies ###
  policy {
    xml_content = <<XML
    <!--
      IMPORTANT:
      - Policy elements can appear only within the <inbound>, <outbound>, <backend> section elements.
      - Only the <forward-request> policy element can appear within the <backend> section element.
      - To apply a policy to the incoming request (before it is forwarded to the backend service), place a corresponding policy element within the <inbound> section element.
      - To apply a policy to the outgoing response (before it is sent back to the caller), place a corresponding policy element within the <outbound> section element.
      - To add a policy position the cursor at the desired insertion point and click on the round button associated with the policy.
      - To remove a policy, delete the corresponding policy statement from the policy document.
      - Policies are applied in the order of their appearance, from the top down.
    -->
    <policies>
      <inbound>
        <cors allow-credentials="true">
            <!-- AllowedOrigins: -->
            <!-- The origin domains that are permitted to make a request against the storage service via CORS. -->
            <!-- The origin domain is the domain from which the request originates. -->
            <!-- Note that the origin must be an exact case-sensitive match with the origin that the user age sends to the service. -->
            <!-- You can also use the wildcard character '*' to allow all origin domains to make requests via CORS. -->
            <allowed-origins>
                <origin>https://${var.environment}-mycompany-apim.azure-api.net</origin>
                <origin>https://${var.environment}-mycompany-apim.developer.azure-api.net</origin>
            </allowed-origins>
            <allowed-methods preflight-result-max-age="300">
                <method>*</method>
            </allowed-methods>
            <allowed-headers>
                <header>*</header>
            </allowed-headers>
            <expose-headers>
                <header>*</header>
            </expose-headers>
        </cors>
      </inbound>
      <backend>
        <forward-request />
      </backend>
      <outbound />
      <!-- Ref: https://docs.microsoft.com/en-us/azure/api-management/api-management-error-handling-policies -->
      <on-error>
        <set-header name="ErrorSource" exists-action="override">
            <value>@(context.LastError.Source)</value>
        </set-header>
        <set-header name="ErrorReason" exists-action="override">
            <value>@(context.LastError.Reason)</value>
        </set-header>
        <set-header name="ErrorMessage" exists-action="override">
            <value>@(context.LastError.Message)</value>
        </set-header>
        <set-header name="ErrorScope" exists-action="override">
            <value>@(context.LastError.Scope)</value>
        </set-header>
        <set-header name="ErrorSection" exists-action="override">
            <value>@(context.LastError.Section)</value>
        </set-header>
        <set-header name="ErrorPath" exists-action="override">
            <value>@(context.LastError.Path)</value>
        </set-header>
        <set-header name="ErrorPolicyId" exists-action="override">
            <value>@(context.LastError.PolicyId)</value>
        </set-header>
        <set-header name="ErrorStatusCode" exists-action="override">
            <value>@(context.Response.StatusCode.ToString())</value>
        </set-header>
      </on-error>
    </policies>
XML

  }
}
### End of Creating APIM ###

### Create Custom Domain and link to SSL Certificate in Key Vault ###
### Note: key_vault_id - URL Comes from: ### 
###  Key vaults --> KEYVAULT --> Settings --> Certificates --> SSLCERTIFICATEINKEYVAULT --> Completed --> CURRENT VERSION --> Properties --> Secret Identifier ###
### Note: Custom Domain should show up in APIM: ###
### APIMINSTNACE --> Deployment and infrastructure --> Custom domains ###  
#resource "azurerm_api_management_custom_domain" "prod" {
#  api_management_id = azurerm_api_management.base.id
#
#  proxy {
#    default_ssl_binding = true
#    host_name    = var.customdomain
#    key_vault_id = var.keyvaultsecretid
#    negotiate_client_certificate = false
#  }
#
#  depends_on = [azurerm_api_management.base]
#}

### Create AAD Identity Provider ###
resource "azurerm_api_management_identity_provider_aad" "base" {
  api_management_name = azurerm_api_management.base.name
  resource_group_name = azurerm_resource_group.base.name
  client_id           = var.aadid
  client_secret       = var.aadsec
  allowed_tenants     = [var.aadten]
}

### Upload Root CA Certificate into APIM Security --> CA Certificates ###
resource "null_resource" "ImportRootCACert" {
  triggers = {lastRunTimestamp = timestamp()}

### Upload Root CA Certificate into APIM Security --> CA Certificates ###
##resource "null_resource" "ImportRootCACert" {
##  triggers = {lastRunTimestamp = timestamp()}

### Upload Root CA Certificate into APIM Security --> CA Certificates ###
resource "null_resource" "ImportRootCACert" {
  triggers = {lastRunTimestamp = timestamp()}

  # Upload Root CA Certificate into APIM Security --> CA Certificates
  provisioner "local-exec" {

    # This works for calling PowerShell Script
    # Note: scripts and sslcerts directories and their contents must be inside the preprod directory so they are part of the published artifacts to get downloaded.
    command = "scripts/ImportRootCA.ps1 -ResourceGroup ${local.prefix}rg${local.suffix} -RootCAPath sslcerts/DOMAINRootCA1.cer -APIMInstance ${var.environment}-church-${var.service} -SubscriptionId ${var.subscriptionid} -TenantID ${var.aadten} -UserAssignedIdentity ${var.userassignedidentity}"
    # For Windows:
    #interpreter = ["PowerShell", "-Command"]
    #interpreter = ["PowerShell", "-File"]
    # For Linux:
    interpreter = ["pwsh", "-Command"]
    #interpreter = ["pwsh", "-File"]

  }

  depends_on = [azurerm_api_management.base]
}


