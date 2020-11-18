<#
.SYNOPSIS
  This script will import a Root CA Certificate into APIM Security--> CA certificates
  
.DESCRIPTION
  This script will import a Root CA Certificate into APIM Security--> CA certificates using Terraform
  Note: This runs in console mode so no log file will be created.
  Based on:
  https://docs.microsoft.com/en-us/powershell/module/az.apimanagement/new-azapimanagementsystemcertificate?view=azps-5.0.0
  https://docs.microsoft.com/en-us/powershell/module/az.apimanagement/set-azapimanagement?view=azps-5.0.0

  Example Terraform:
  Note: this goes inside of your APIM Terraform definition:
  resource "azurerm_api_management" "base" {
   APIM Definition goes here.
  }
  # Upload Root CA Certificate
  provisioner "local-exec" {
        command = "powershell -file ./scripts/mportRootCA.ps1 -ResourceGroup ${local.prefix}rg${local.suffix} -RootCAPath ./sslcerts/RootCA1.cer -APIMInstance ${var.environment}-company-${var.service} -SubscriptionId ${var.subscriptionid}"
  }

  Ref:
  https://stackoverflow.com/questions/57046615/how-to-execute-powershell-file-in-azure-from-terraform-both-from-local-and-from

.PARAMETER ResourceGroup
    The Azure APIM Resource Group

.PARAMETER RootCAPath
    The Root CA Certificate path to import

.PARAMETER Location
    The Location of the APIM instance

.PARAMETER APIMInstance
    The Name of the APIM instance

.INPUTS
  None
  
.OUTPUTS
  None
  
.NOTES
  Script Name: ImportAzureRootCA.ps1
  Version:        1.0
  Author:         Richard Knechtel
  Creation Date:  09/14/2020
  Purpose/Change: Initial script development
  
.EXAMPLE
  Note this is called from Terraform thus Terraform Variables
  ./ImportAzureRootCA.ps1 -ResourceGroup ${local.prefix}rg${local.suffix} -RootCAPath ./sslcerts/RootCA1.cer -APIMInstance ${var.environment}-ccmapny-${var.service} -SubscriptionId ${var.subscriptionid}
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------
param(
[Parameter(Mandatory=$true)]
[string]$ResourceGroup,
[Parameter(Mandatory=$true)]
[string]$RootCAPath,
[Parameter(Mandatory=$true)]
[string]$APIMInstance,
[Parameter(Mandatory=$true)]
[string]$SubscriptionId
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

$global:ReturnCodeMsg = "Completed Successfully"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$ScriptVersion = "1.0"

#-----------------------------------------------------------[Functions]------------------------------------------------------------

N/A

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host "Starting ImportAzureRootCA script Version $ScriptVersion.";
Write-Host "*******************************************************";

try 
{
  Write-Host "Starting Import of Root CA Certificate";
  
  # Connect to Aure
  #Connect-AzAccount
  
  # Get Subscription Context
  $context = Get-AzSubscription -SubscriptionId $SubscriptionId
  Set-AzContext $context

  # Run the Import of the Root CA Certificate
  $rootCa = New-AzApiManagementSystemCertificate -StoreName "Root" -PfxPath "$RootCAPath"
  $systemCert = @($rootCa)

  # Get handle to APIM Instance
  $apim = Get-AzApiManagement -ResourceGroupName "$ResourceGroup" -Name "$APIMInstance"
  $apim.SystemCertificates = $systemCert
  
  # Update APIM
  Set-AzApiManagement -InputObject $apim

  Write-Host "Finished Import of Root CA Certificate";
}  
catch
{
  # Catch any errors and report them
  $ErrorMessage = $_.Exception.Message;
  $FailedItem = $_.Exception.ItemName;
  Write-Host "Exception caught in ImportAzureRootCA: $ErrorMessage";
  Write-Host "Exception caught in ImportAzureRootCA - failed at: $FailedItem";
}
finally
{
  Write-Host "Finished running ImportAzureRootCA script Version $ScriptVersion.";
  Write-Host "**************************************************************";

  # Example setting return code/message
  $global:ReturnCodeMsg="There was an Error in ImportAzureRootCA."
}

# Some Value or Variable
return $ReturnCodeMsg
