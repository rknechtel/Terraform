#! /usr/bin/pwsh
# Note: Need the above to run PowerShell Scripts in Linux.
<#
.SYNOPSIS
  This script will import a Root CA Certificate into APIM Security --> Certificates --> CA Certificates
  
.DESCRIPTION
  This script will import a Root CA Certificate into APIM Security --> Certificates --> CA Certificates using Terraform
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

.LICENSE
 This script is in the public domain, free from copyrights or restrictions.

 
.EXAMPLE
  Note this is called from Terraform thus Terraform Variables
  ./ImportRootCA.ps1 -ResourceGroup ${local.prefix}rg${local.suffix} -RootCAPath ./sslcerts/MYDOMAINRootCA1.cer -APIMInstance ${var.environment}-mycompany-${var.service} -SubscriptionId ${var.subscriptionid} -TenantID ${var.tenant} -UserAssignedIdentity ${var.userassignedidentity}
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
[string]$TenantID,
[Parameter(Mandatory=$true)]
[string]$UserAssignedIdentity
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
#$ErrorActionPreference = 'SilentlyContinue'

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
  Write-Host "APIM Instance = $APIMInstance";
  Write-Host "Root CA Path = $RootCAPath";
  Write-Host "Usesr Assigned Identity = $UserAssignedIdentity";

  Write-Host "Starting Import of Root CA Certificate";
  
  # Install the Azure PowerShell commandlets if they are not installed
  Write-Host "Installing Az module";
  if (Get-Module -ListAvailable -Name Az) {
    Write-Host "Az Module already installed"
  } 
  else {
    Write-Host "Az Module is not installed - Installing...."
    #Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force

    Write-Host "Az.Accounts Module is not installed - Installing...."
    Install-Module -Name Az.Accounts -AllowClobber -Scope CurrentUser -Force

    Write-Host "Az.ApiManagement Module is not installed - Installing...."
    Install-Module -Name Az.ApiManagement -AllowClobber -Scope CurrentUser -Force
    
    Write-Host "Az.ManagedServiceIdentity Module is not installed - Installing...."
    Install-Module -Name Az.ManagedServiceIdentity -AllowClobber -Scope CurrentUser -Force
  }

  # Connect to Azure
  # Note: When running in Azure Pipelines (ADO) - Error from Get-AzUserAssignedIdentity:
  # "Run Connect-AzAccount to login."
  # Catch-22:
  # Running Get-AzUserAssignedIdentity Erros with "Run Connect-AzAccount to login", but I need the Identity from Get-AzUserAssignedIdentity to run "Connect-AzAccount".
  # Seems you might need to connect to Azure with a service account first.

  Write-Host "Connect to Azure using User Assigned Identity $UserAssignedIdentity";
  Write-Host "Get-AzUserAssignedIdentity -ResourceGroupName "$ResourceGroup" -Name "$UserAssignedIdentity" | Select-Object -ExpandProperty ClientID"
  $identity = Get-AzUserAssignedIdentity -ResourceGroupName "$ResourceGroup" -Name "$UserAssignedIdentity" | Select-Object -ExpandProperty ClientID -ErrorAction Continue
 
  Write-host "Returned Identity = $identity"

  if ($null -eq $identity) {
    Write-Host "identity is null"
    throw [System.NullReferenceException]::New('identity is null!')
  }
  else {

    Write-Host "identity is not null: $identity"

    write-host "Connect-AzAccount -Identity -AccountId $identity"
    Connect-AzAccount -Identity -AccountId $identity

    # Get Subscription Context (Must connect to Azure First)
    Write-Host "Gettting AzSubscription: $SubscriptionId"
    $context = Get-AzSubscription -SubscriptionId $SubscriptionId
    Set-AzContext $context

    # Get handle to APIM Instance
    Write-Host "Getting handle to APIM";
    $apim = Get-AzApiManagement -ResourceGroupName "$ResourceGroup" -Name "$APIMInstance"

    # Check if We have System Certificates or not
    Write-Host "Check if We have System Certificates or not";
    if ($null -eq $apim.SystemCertificates) {

      Write-Host "We do not have System Certificates";

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
    else {
      Write-Host "We already have a System Certificates";
    }
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
  #$global:ReturnCodeMsg="There was an Error in ImportRootCA."
}

return $LASTEXITCODE
