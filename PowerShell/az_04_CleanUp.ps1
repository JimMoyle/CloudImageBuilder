<#
.Synopsis
   CleanUp, using Azure Image Builder (Module Az)
.DESCRIPTION
   CleanUp, using Azure Image Builder (Module Az)
.NOTES
   Author: Esther Barthel, MSc
   Version: 0.1
   Created: 2019-08-19
   Updated: 

   Research Links: https://docs.microsoft.com/en-us/powershell/azure/overview?view=azps-1.6.0
                   https://docs.microsoft.com/en-us/azure/virtual-machines/windows/image-builder
                   https://github.com/danielsollondon/azvmimagebuilder/blob/master/quickquickstarts/0_Creating_a_Custom_Windows_Managed_Image/readme.md
#>

#region Config Variables
    $aibAppID = "cf32a0cc-373c-47c9-9156-0db11f6a6dfc"
#endregion

#region Pre-check: Check if Module Az is installed
    Write-Output ""
    Write-Output "Pre-Check: Check if the Az Module is already installed: "
    If ($null -eq (Get-InstalledModule -Name Az -ErrorAction SilentlyContinue))
    # $env:psmodulePath (C:\Users\blkrogue\Documents\WindowsPowerShell\Modules;C:\Program Files\WindowsPowerShell\Modules;C:\Windows\system32\WindowsPowerShell\v1.0\Modules;C:\Program Files\Intel\Wired Networking\)
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
$AzSession = Connect-AzAccount

# Get the tenantID from the session
$tenantID = $AzSession.Context.Tenant.TenantId

Write-Verbose " * Creating a Custom Windows Managed Image w/ Azure Image Builder service - CleanUp"

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
#endregion Set Variables

# azure CLI:
#az resource delete \
#    --resource-group $imageResourceGroup \
#    --resource-type Microsoft.VirtualMachineImages/imageTemplates \
#    -n helloImageTemplateWin01
Remove-AzResource -ResourceGroupName $imageResourceGroup -ResourceType "Microsoft.VirtualMachineImages/imageTemplates" -ResourceName "helloImageTemplateWin02"

# azure CLI:
#az group delete -n $imageResourceGroup
Get-AzResourceGroup -Name $imageResourceGroup | Remove-AzResourceGroup -Force -Verbose

# Logoff Azure session (without any output and session information)
Disconnect-AzAccount | Out-Null




