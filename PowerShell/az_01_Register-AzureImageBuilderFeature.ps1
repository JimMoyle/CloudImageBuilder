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
                   https://github.com/danielsollondon/azvmimagebuilder/tree/master/quickquickstarts/0_Creating_a_Custom_Windows_Managed_Image
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

# Step 1: Register for Image Builder/VM/Storage features
# azure CLI: azure feature register --namespace Microsoft.VirtualMachineImages --name VirtualMachineTemplatePreview
Register-AzProviderFeature -ProviderNamespace Microsoft.VirtualMachineImages -FeatureName VirtualMachineTemplatePreview

# Step 2: Check the status of the feature registration
# azure CLI: az feature show --namespace Microsoft.VirtualMachineImages --name VirtualMachineTemplatePreview | grep state
Get-AzProviderFeature -ProviderNamespace Microsoft.VirtualMachineImages -FeatureName VirtualMachineTemplatePreview
#or
Get-AzProviderFeature -ProviderNamespace Microsoft.VirtualMachineImages
<#
FeatureName                   ProviderName                   RegistrationState
-----------                   ------------                   -----------------
VirtualMachineTemplatePreview Microsoft.VirtualMachineImages Registered       
#>

Get-AzProviderFeature -ProviderNamespace Microsoft.Storage
<# 
$null

NOTE: the azure CLI does return information:
      x@Azure:~$ az provider show -n Microsoft.Storage | grep registrationState
        "registrationState": "Registered",
      x@Azure:~$
#>


# Logoff Azure session
Disconnect-AzAccount | Out-Null


