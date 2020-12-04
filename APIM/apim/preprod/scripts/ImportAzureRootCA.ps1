#! /usr/bin/pwsh
# Note: Need the above to run PowerShell Scripts in Linux.
<#
.SYNOPSIS
  This script will import a Root CA Certificate into APIM Security--> CA certificates
  
.DESCRIPTION
  This script will import a Root CA Certificate into APIM Security--> CA certificates using Terraform
  Note: This runs in console mode so no log file will be created.
  Based on:
  https://docs.microsoft.com/en-us/powershell/module/az.apimanagement/new-azapimanagementsystemcertificate?view=azps-5.0.0
  https://docs.microsoft.com/en-us/powershell/module/az.apimanagement/set-azapimanagement?view=azps-5.0.0
    
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
  Script Name: ImportRootCA.ps1
  Version:        1.0
  Author:         Richard Knechtel
  Creation Date:  11/11/2020
  Purpose/Change: Initial script development
  
.EXAMPLE
  Note this is called from Terraform thus Terraform Variables
  ./ImportRootCA.ps1 -ResourceGroup ${local.prefix}rg${local.suffix} -RootCAPath ./sslcerts/MYDOMAINCA1.cer -APIMInstance ${var.environment}-mycompany-${var.service} -SubscriptionId ${var.subscriptionid} -TenantID ${var.tenant}
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
[string]$SubscriptionId,
[Parameter(Mandatory=$true)]
[string]$TenantID
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

Write-Host "Starting ImportRootCA script Version $ScriptVersion.";
Write-Host "*******************************************************";

try 
{
  Write-Host "Starting Import of Root CA Certificate";

  # Parameters Passed:
  Write-Host "Resource Group = $ResourceGroup";
  Write-Host "Root CA Path = $RootCAPath";
  Write-Host "APIM Instance = $APIMInstance";
  Write-Host "Starting Import of Root CA Certificate";
  
  # Install the Azure PowerShell commandlets
  Write-Host "Installing Az module";
  #Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force

  # Connect to Azure
  Write-Host "Connect to Azure";
  Connect-AzAccount -Tenant $TenantID -SubscriptionId $SubscriptionId

  # Get Subscription Context
  Write-Host "Gettting AzSubscription: $SubscriptionId";
  $context = Get-AzSubscription -SubscriptionId $SubscriptionId
  Set-AzContext $context

  # Get handle to APIM Instance
  Write-Host "Getting handle to APIM";
  $apim = Get-AzApiManagement -ResourceGroupName "$ResourceGroup" -Name "$APIMInstance"

  # Check if We have System Certificates or not
  Write-Host "Check if We have System Certificates or not";
  if ($apim.SystemCertificates -eq $null) {

    # Run the Import of the Root CA Certificate
    Write-Host "Creating New APIM System Certificate";
    $rootCa = New-AzApiManagementSystemCertificate -StoreName "Root" -PfxPath "$RootCAPath"
    $systemCert = @($rootCa)

    # System Certificate to APIM
    $apim.SystemCertificates = $systemCert
  
    # Update APIM
    Write-Host "Updating APIM With System Root CA Certificate.";
    Set-AzApiManagement -InputObject $apim

    Write-Host "Finished Import of Root CA Certificate";
  }

}  
catch
{
  # Catch any errors and report them
  $ErrorMessage = $_.Exception.Message;
  $FailedItem = $_.Exception.ItemName;
  Write-Host "Exception caught in ImportRootCA: $ErrorMessage";
  Write-Host "Exception caught in ImportRootCA - failed at: $FailedItem";
}
finally
{
  Write-Host "Finished running ImportRootCA script Version $ScriptVersion.";
  Write-Host "**************************************************************";

  # Example setting return code/message
  $global:ReturnCodeMsg="There was an Error in ImportRootCA."
}

# Some Value or Variable
return $ReturnCodeMsg

