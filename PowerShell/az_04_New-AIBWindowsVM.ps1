<#
.Synopsis
   Create a Windows VM, using Azure Image Builder (Module Az)
.DESCRIPTION
   Create a Windows VM, using Azure Image Builder (Module Az)
.NOTES
   Author: Esther Barthel, MSc
   Version: 0.2
   Created: 2019-08-09
   Updated: 2019-09-15
            Added new variable names and custom template processing in

   Research Links: https://docs.microsoft.com/en-us/powershell/azure/overview?view=azps-1.6.0
                   https://docs.microsoft.com/en-us/azure/virtual-machines/windows/image-builder
#>

#region Config Constants
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
#endregion

Write-Verbose " * Creating a Custom Windows Managed Image w/ Azure Image Builder service - Template Artifact"

#region Set AIB Variables
    # Resource group name - we are using myImageBuilderRG in this example
    $imageResourceGroup="aibImageRG"
    # Region location 
    $location="WestUS2"
    # name of the image to be created
    $imageName="aibWVDGoldenImage"
    # name of the VM to create from image
    $vmName = "aibWVDVM00"
#endregion

# Prep: VM admin username & password
$VMLocalAdminUser = "aibuser"
$VMLocalAdminSecurePassword = ConvertTo-SecureString "AIBUserPassword01!" -AsPlainText -Force
# Prep: Transfer username and password into a PSCredential object
$VMCredential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword)

#Create a new VM, based on the image
#azure CLI: az vm create --resource-group $imageResourceGroup --name aibImgWinVm00 --admin-username aibuser --admin-password $vmpassword --image $imageName --location $location
$aibVM = New-AzVM -ResourceGroupName $imageResourceGroup -Name $vmName -Image $imageName -Credential $VMCredential -Location $location

# NOTE: It takes a while for the VM to be created and the prompt is returned (progress is being shown)

## Check if VM is created
#Get-AzVM -ResourceGroupName $imageResourceGroup -Name "aibImgWinVM00"


# Logoff Azure session (without any output and session information)
Disconnect-AzAccount | Out-Null

