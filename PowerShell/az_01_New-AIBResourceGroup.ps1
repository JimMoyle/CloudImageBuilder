<#
.Synopsis
   Create a new Resource Group for Azure Image Builder images, using Azure Image Builder (Module Az)
.DESCRIPTION
   Create a new Resource Group for Azure Image Builder images, using Azure Image Builder (Module Az)
.NOTES
   Author: Esther Barthel, MSc
   Version: 0.1
   Created: 2019-08-09
   Updated: 

   Research Links: https://docs.microsoft.com/en-us/powershell/azure/overview?view=azps-1.6.0
                   https://docs.microsoft.com/en-us/azure/virtual-machines/windows/image-builder
                   https://github.com/danielsollondon/azvmimagebuilder/blob/master/quickquickstarts/0_Creating_a_Custom_Windows_Managed_Image/readme.md
#>

#region Config Constants
    # given App ID of the Azure Image Builder service
    $aibAppID = "cf32a0cc-373c-47c9-9156-0db11f6a6dfc"       
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

#region Subscription information
    # Get the tenantID from the session
    $tenantID = $AzSession.Context.Tenant.TenantId
    # Get SubscriptionID for the given TenantID
    $subscriptionID = (Get-AzSubscription -TenantId $TenantID).SubscriptionId
#endregion


Write-Verbose " * Creating a Custom Windows Managed Image w/ Azure Image Builder service - New ResourceGroup"

#region Set AIB Variables
    # Resource group name - we are using myImageBuilderRG in this example
    $imageResourceGroup="aibImageRG"
    # Region location 
    $location="WestUS2"
#endregion Set Variables

# create a resource group to store the image configuration template artifact and the image
$aibRG = New-AzResourceGroup -Name $imageResourceGroup -Location $location

## Check if the resource group creation is successful
#Get-AzResourceGroup -Id ($aibRG.ResourceId)

# Set Permission on the Resource Group (The --assignee value is the app registration ID for the Image Builder service.)
# Azure CLI: az role assignment create --assignee cf32a0cc-373c-47c9-9156-0db11f6a6dfc --role Contributor --scope /subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup
    #--assignee: Represent a user, group, or service principal. supported format: object id, user sign-in name, or service principal name.
    #            => translated to the PowerShell parameter ApplicationId 
$aibRoleAssignment = New-AzRoleAssignment -ApplicationId $aibAppID -RoleDefinitionName Contributor -Scope "/subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup"

## Check if the role assignment was successful
#Get-AzRoleAssignment -ObjectId ($aibRoleAssignment.ObjectId)


# Logoff Azure session (without any output and session information)
Disconnect-AzAccount | Out-Null
