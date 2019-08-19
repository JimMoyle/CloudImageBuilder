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

#region Config Variables
    $aibAppID = "cf32a0cc-373c-47c9-9156-0db11f6a6dfc"       # given App ID of the Azure Image Builder service
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

# Get the tenantID from the session
$tenantID = $AzSession.Context.Tenant.TenantId

Write-Verbose " * Creating a Custom Windows Managed Image w/ Azure Image Builder service - New ResourceGroup"

#region Set AIB Variables
    # Resource group name - we are using myImageBuilderRG in this example
    $imageResourceGroup="myWinImgBuilderRG"
    # Region location 
    $location="WestUS2"
    # Run output name
    $runOutputName="aibWindows"
    # name of the image to be created
    $imageName="aibWinImage"

    # Get SubscriptionID for the given TenantID
    $subscriptionID = (Get-AzSubscription -TenantId $TenantID).SubscriptionId

    # JSON template file
    $JSONTemplateFile = "C:\_GitHub\CloudImageBuilder\PowerShell\helloImageTemplateWin.json"
#endregion Set Variables

# create a resource group to store the image configuration template artifact and the image
$aibRG = New-AzResourceGroup -Name $imageResourceGroup -Location $location

<#
ResourceGroupName : myWinImgBuilderRG
Location          : westus2
ProvisioningState : Succeeded
Tags              : 
ResourceId        : /subscriptions/<id>/resourceGroups/myWinImgBuilderRG
#>

# Set Permission on the Resource Group (The --assignee value is the app registration ID for the Image Builder service.)
<# Azure CLI:
    #--assignee
    # Represent a user, group, or service principal. supported format: object id, user sign-in name, or service principal name.
    # => translated to the PowerShell parameter
    # - ObjectId = Azure AD ObjectId of the user, group or service principal.
    # - ApplicationId = Application ID 
#>
New-AzRoleAssignment -ApplicationId $aibAppID -RoleDefinitionName Contributor -Scope "/subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup"

<#
    RoleAssignmentId   : /subscriptions/<id>/resourceGroups/myWinImgBuilderRG/providers/Microsoft.Authorization/roleAssignments/<id>
    Scope              : /subscriptions/<id>/resourceGroups/myWinImgBuilderRG
    DisplayName        : Azure Virtual Machine Image Builder
    SignInName         : 
    RoleDefinitionName : Contributor
    RoleDefinitionId   : <id>
    ObjectId           : <id>
    ObjectType         : ServicePrincipal
    CanDelegate        : False
#>


# Logoff Azure session (without any output and session information)
Disconnect-AzAccount | Out-Null
