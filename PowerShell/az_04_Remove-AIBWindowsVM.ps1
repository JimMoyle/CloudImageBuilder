<#
.Synopsis
   Remove the Azure Image Builder Windows VM, using Azure Image Builder (Module Az)
.DESCRIPTION
   Remove the Azure Image Builder Windows VM, using Azure Image Builder (Module Az)
.NOTES
   Author: Esther Barthel, MSc
   Version: 0.1
   Created: 2019-08-20
   Updated: 

   Research Links: https://docs.microsoft.com/en-us/powershell/azure/overview?view=azps-1.6.0
                   https://docs.microsoft.com/en-us/azure/virtual-machines/windows/image-builder
                   https://github.com/danielsollondon/azvmimagebuilder/blob/master/quickquickstarts/0_Creating_a_Custom_Windows_Managed_Image/readme.md
#>

#region Config Variables
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

Write-Verbose " * Creating a Custom Windows Managed Image w/ Azure Image Builder service - CleanUp VM"

#region Set AIB Variables
    # Resource group name - we are using myImageBuilderRG in this example
    $imageResourceGroup="aibImageRG"
    # Region location 
    $location="WestUS2"
    # name of the image to be created
    $imageName="aibWinImage"
    # name of the VM to create from image
    $vmName = "aibImgWinVM00"
#endregion Set Variables

# Remove the created VM, based on the Azure Image Builder image
Get-AzVM -ResourceGroupName $imageResourceGroup -Name $vmName | Remove-AzVM -Force
# NOTE: This will not remove the linked Network interface, Network Security Group, Plubic IP address, Virtual network and Disk !!!!!


# Logoff Azure session (without any output and session information)
Disconnect-AzAccount | Out-Null




