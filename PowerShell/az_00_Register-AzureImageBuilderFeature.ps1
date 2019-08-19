<#
.Synopsis
   Register AIB Feature, using Azure PowerShell (Module Az)
.DESCRIPTION
   Register AIB Feature, using Azure PowerShell (Module Az)
.NOTES
   Author: Esther Barthel, MSc
   Version: 0.1
   Created: 2019-08-09
   Updated: 

   Research Links: https://docs.microsoft.com/en-us/powershell/azure/overview?view=azps-1.6.0
                   https://docs.microsoft.com/en-us/azure/virtual-machines/windows/image-builder
#>

#region Config Variables
#endregion

#region Pre-check: Check if Module Az is installed
    Write-Output ""
    Write-Output "Pre-Check: Check if the Az Module is already installed: "
    If ($null -eq (Get-InstalledModule -Name Az -ErrorAction SilentlyContinue))
    {
        Write-Output " => Module Az is NOT installed"
        Break
    }
    Else
    {
        Write-Output " => Module Az is installed"
    }
#endregion

#Login with account credentials to set this for the subscription (interactive logon)
$azSession = Connect-AzAccount

Write-Verbose " * Register for the Azure Image Builder service"

# Following the steps from https://docs.microsoft.com/en-us/azure/virtual-machines/windows/image-builder

# Step 1: Register the feature
Register-AzProviderFeature -ProviderNamespace Microsoft.VirtualMachineImages -FeatureName VirtualMachineTemplatePreview

# Step 2: Check the status of the feature registration
Get-AzProviderFeature -ProviderNamespace Microsoft.VirtualMachineImages -FeatureName VirtualMachineTemplatePreview

<#
PS C:\Users> Register-AzProviderFeature -FeatureName VirtualMachineTemplatePreview -ProviderNamespace Microsoft.VirtualMachineImages

FeatureName                   ProviderName                   RegistrationState
-----------                   ------------                   -----------------
VirtualMachineTemplatePreview Microsoft.VirtualMachineImages Registering      
#>

# Step 3: Check your registration
Get-AzProviderFeature -ProviderNamespace Microsoft.VirtualMachineImages
<#
FeatureName                   ProviderName                   RegistrationState
-----------                   ------------                   -----------------
VirtualMachineTemplatePreview Microsoft.VirtualMachineImages Registered       
#>

Get-AzProviderFeature -ProviderNamespace Microsoft.Storage
<# 
$null

Note: the azure CLI does return information:
      x@Azure:~$ az provider show -n Microsoft.Storage | grep registrationState
        "registrationState": "Registered",
      x@Azure:~$
#>

# Register-AzProviderFeature -ProviderNamespace Microsoft.VirtualMachineImages # => requires the FeatureName to be specified as well !!!
# Register-AzProviderFeature -ProviderNamespace Microsoft-Storage              # => requires the FeatureName to be specified as well !!!


# Logoff Azure session
Disconnect-AzAccount | Out-Null


