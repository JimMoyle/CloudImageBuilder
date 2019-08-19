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

    # JSON template file
    $JSONTemplateFile = "C:\_GitHub\CloudImageBuilder\PowerShell\helloImageTemplateWin.json"
#endregion Set Variables

# Download the template file template (with placeholders) from Daniel Sol's github with Invoke-WebRequest cmdlet
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/quickquickstarts/0_Creating_a_Custom_Windows_Managed_Image/helloImageTemplateWin.json" -OutFile $JSONTemplateFile

# Replace the placeholders with the variables
$fileContent = Get-Content -Path $JSONTemplateFile -Raw
$fileContent = $fileContent.Replace("<subscriptionID>",$subscriptionID)
$fileContent = $fileContent.Replace("<rgName>",$imageResourceGroup)
$fileContent = $fileContent.Replace("<region>",$location)
$fileContent = $fileContent.Replace("<imageName>",$imageName)
$fileContent = $fileContent.Replace("<runOutputName>",$runOutputName)

# Save the replaced content in the original file
$fileContent | Set-Content -Path $JSONTemplateFile

$JSONConfigFile = (Get-Content -Path $JSONTemplateFile) | ConvertFrom-Json
# Create the image template
# Azure CLI:
#--properties -p
# A JSON-formatted string containing resource properties.
# => translates to the PowerShell parameter
# -Properties

## Check the type
#$JSONConfigFile.GetType().FullName
# System.Management.Automation.PSCustomObject

## Check the property names
#$JSONConfigFile.PSObject.Properties.Name
#type
#apiVersion
#location
#dependsOn
#tags
#properties

# submit the image configuration to the VM Image Builder Service (Create the image template artifact)
# azure CLI:
    #az resource create \
    #    --resource-group $imageResourceGroup \
    #    --properties @helloImageTemplateWin.json \
    #    --is-full-object \
    #    --resource-type Microsoft.VirtualMachineImages/imageTemplates \
    #    -n helloImageTemplateWin01

New-AzResource -ResourceGroupName $imageResourceGroup -ResourceName "helloImageTemplateWin02" -ResourceType "Microsoft.VirtualMachineImages/ImageTemplates" -Properties $JSONConfigFile -IsFullObject -Verbose

# wait approx 1-3mins, depending on external links


# NOTE: This cmdlet generates an error right now, consulting with Daniel Sol to get a working PowerShell example from him in regards to the Properties argument formatting.


    <#When complete, this will return a success message back to the console, and create an Image Builder Configuration Template in the $imageResourceGroup. 
    You can see this resource in the resource group in the Azure portal, if you enable 'Show hidden types'.
    In the background, Image Builder will also create a staging resource group in your subscription. 
    This resource group is used for the image build. It will be in this format: IT_<DestinationResourceGroup>_<TemplateName>
    #>

    # source: https://cloudblogs.microsoft.com/opensource/2019/05/07/announcing-the-public-preview-of-azure-image-builder/


# start the image build
# azure CLI:
    #az resource invoke-action \
    #     --resource-group $imageResourceGroup \
    #     --resource-type  Microsoft.VirtualMachineImages/imageTemplates \
    #     -n helloImageTemplateWin01 \
    #     --action Run 

# Build the image, based on the template artifact
Invoke-AzResourceAction -ResourceGroupName $imageResourceGroup -ResourceType "Microsoft.VirtualMachineImages/ImageTemplates" -ResourceName "helloImageTemplateWin02" -Action "Run"

# wait approx 15mins

# Logoff Azure session (without any output and session information)
Disconnect-AzAccount | Out-Null
