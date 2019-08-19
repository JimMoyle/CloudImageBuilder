<#
.Synopsis
   Create a Windows VM, using Azure Image Builder (Module Az)
.DESCRIPTION
   Create a Windows VM, using Azure Image Builder (Module Az)
.NOTES
   Author: Esther Barthel, MSc
   Version: 0.1
   Created: 2019-08-09
   Updated: 

   Research Links: https://docs.microsoft.com/en-us/powershell/azure/overview?view=azps-1.6.0
                   https://docs.microsoft.com/en-us/azure/virtual-machines/windows/image-builder
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

Write-Verbose " * Creating a Custom Windows Managed Image w/ Azure Image Builder service - Template Artifact"

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

# create the VM
#azure CLI
#az vm create \
    #  --resource-group $imageResourceGroup \
    #  --name aibImgWinVm00 \
    #  --admin-username aibuser \
    #  --admin-password $vmpassword \
    #  --image $imageName \
    #  --location $location

# VM admin username & password
$VMLocalAdminUser = "aibuser"
$VMLocalAdminSecurePassword = ConvertTo-SecureString "AIBUserPassword01!" -AsPlainText -Force

# Transfer username and password into a PSCredential object
$VMCredential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword)

#Create a new VM, based on the image
New-AzVM -ResourceGroupName $imageResourceGroup -Name "aibImgWinVM00" -Image $imageName -Credential $VMCredential -Location $location 

# Logoff Azure session (without any output and session information)
Disconnect-AzAccount | Out-Null

