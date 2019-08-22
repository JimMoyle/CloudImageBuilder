<#
.Synopsis
   Remove the Azure Image Builder Image Template and Resource Group, using Azure Image Builder (Module Az)
.DESCRIPTION
   Remove the Azure Image Builder Image Template and Resource Group, using Azure Image Builder (Module Az)
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

Write-Verbose " * Creating a Custom Windows Managed Image w/ Azure Image Builder service - CleanUp"

#region Set AIB Variables
    # Resource group name - we are using myImageBuilderRG in this example
    $imageResourceGroup="aibImageRG"
    # resource Type
    $resourceType = "Microsoft.VirtualMachineImages/imageTemplates"
    # resource Name
    $resourceName = "helloImageTemplateWin01"
    # name of the image to be created
    $imageName="aibWinImage"
#endregion Set Variables

# Remove the Azure Image Builder Image (resource)
Remove-AzImage -ResourceGroupName $imageResourceGroup -ImageName $imageName -Force

# Remove the Azure Image Builder Image Template (resource)
# azure CLI: #az resource delete --resource-group $imageResourceGroup --resource-type Microsoft.VirtualMachineImages/imageTemplates -n helloImageTemplateWin01
Remove-AzResource -ResourceGroupName $imageResourceGroup -ResourceType $resourceType -ResourceName $resourceName -Force -Verbose

# NOTE: This might take a couple of minutes to be performed

## Check if the resource (template) is removed
#Get-AzResource -ResourceGroupName $aibResourceGroup -ResourceType $resourceType -ResourceName $resourceName -Verbose

#Get-AzResource : The Resource 'Microsoft.VirtualMachineImages/imageTemplates/helloImageTemplateWin01' under resource group 'myWinImgBuilderRG' was not found.

#NOTE: It takes a couple of minutes before the template is removed
#NOTE: The temporary created resource group IT_myWinImgBuilderRG_helloImageTemplateWin01 was automatically deleted when the template was deleted


# Remove the Resource Group as well
# azure CLI: az group delete -n $imageResourceGroup
Get-AzResourceGroup -Name $imageResourceGroup | Remove-AzResourceGroup -Force -Verbose

## Check if the RG is removed
#Get-AzResourceGroup -Name $aibResourceGroup

# Logoff Azure session (without any output and session information)
Disconnect-AzAccount | Out-Null




