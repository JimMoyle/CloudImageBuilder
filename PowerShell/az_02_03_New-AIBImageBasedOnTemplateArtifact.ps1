<#
.Synopsis
   Create a Windows VM, using Azure Image Builder (Module Az)
.DESCRIPTION
   Create a Windows VM, using Azure Image Builder (Module Az)
.NOTES
   Author: Esther Barthel, MSc
   Version: 0.3
   Created: 2019-08-09
   Updated: 2019-08-22
            Fixed the not working cmdlet for the image template upload to the Azure Image Builder service, 
            thanks to Daniel Sol for providing the correct cmdlet and template file
   Updated: 2019-09-15
            Created a new custom template with the Office365 ProPlus and OneDrive per-machine installations in it

   Research Links: https://docs.microsoft.com/en-us/powershell/azure/overview?view=azps-1.6.0
                   https://docs.microsoft.com/en-us/powershell/module/azurerm.resources/new-azurermresourcegroupdeployment?view=azurermps-6.13.0
                   https://docs.microsoft.com/en-us/azure/virtual-machines/windows/image-builder
                   https://github.com/danielsollondon/azvmimagebuilder/blob/master/quickquickstarts/0_Creating_a_Custom_Windows_Managed_Image/readme.md
                   https://github.com/danielsollondon/azvmimagebuilder/tree/master/solutions/5_PowerShell_deployments
#>

#region Config Constants
    $apiVersion = "2019-05-01-preview"
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
$AzSession = Connect-AzAccount

#region Subscription information
    # Get the tenantID from the session
    $tenantID = $AzSession.Context.Tenant.TenantId
    # Get SubscriptionID for the given TenantID
    $subscriptionID = (Get-AzSubscription -TenantId $TenantID).SubscriptionId
#endregion

Write-Verbose " * Creating a Custom Windows Managed Image w/ Azure Image Builder Service"

#region Set AIB Variables
    # Resource group name
    $imageResourceGroup="aibImageRG"
    # Region location 
    $location="WestUS2"
    # Run output name
    $runOutputName="aibWindows"
    # name of the image to be created
    $imageName="aibWVDGoldenImage"
    # JSON template file
    $jsonTemplateFile = "C:\_GitHub\CloudImageBuilder\PowerShell\customTemplateWVD.json"
    # Type of the Azure Image Builder Image Template (resource)
    $resourceType = "Microsoft.VirtualMachineImages/ImageTemplates"
    # Name of the Azure Image Builder Image Template (resource)
    $resourceName = "aibWVDTemplate"
    #endregion

# Download the template file template (with placeholders) from Daniel Sol's github with Invoke-WebRequest cmdlet
# azure CLI: curl https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/quickquickstarts/0_Creating_a_Custom_Windows_Managed_Image/helloImageTemplateWin.json -o helloImageTemplateWin.json

# NOTE: Using my new custom template with the Office365 and OneDrive installation in it!!!
$templateUrl="https://publicresources.blob.core.windows.net/downloads/CustomTemplateWVD.json"

# Retrieve the template file and save it locally
Invoke-WebRequest -Uri $templateUrl -OutFile $jsonTemplateFile -UseBasicParsing

# Replace the placeholders with the variables
$fileContent = Get-Content -Path $jsonTemplateFile -Raw
$fileContent = $fileContent.Replace("<subscriptionID>",$subscriptionID)
$fileContent = $fileContent.Replace("<rgName>",$imageResourceGroup)
$fileContent = $fileContent.Replace("<region>",$location)
$fileContent = $fileContent.Replace("<imageName>",$imageName)
$fileContent = $fileContent.Replace("<runOutputName>",$runOutputName)

# Save the replaced content in the original file
$fileContent | Set-Content -Path $jsonTemplateFile

## Create a TemplateParameterObject for the template file input parameters
$objTemplateParameter = @{
    "imageTemplateName"=$resourceName;
    "api-version"=$apiVersion;
    "svclocation"=$location;
}

# submit the template to the Azure Image Builder Service 
# (creates the image template artifact and stores dependent artifacts (scripts, etc) in the staging Resource Group IT_<resourcegroupname>_<temmplatename>)
# azure CLI: az resource create --resource-group $imageResourceGroup --properties @helloImageTemplateWin.json --is-full-object --resource-type Microsoft.VirtualMachineImages/imageTemplates -n helloImageTemplateWin01
New-AzResourceGroupDeployment -ResourceGroupName $imageResourceGroup -Name $resourceName -TemplateFile $jsonTemplateFile -TemplateParameterObject $objTemplateParameter -Verbose | Tee-Object aibImageTemplate

# wait approx 1-3mins, depending on external links
Start-Sleep -Seconds 180

<#
    VERBOSE: Performing the operation "Creating Deployment" on target "aibImageRG".
    VERBOSE: 23:30:31 - Template is valid.
    VERBOSE: 23:30:34 - Create template deployment 'aibWVDTemplate'
    VERBOSE: 23:30:34 - Checking deployment status in 5 seconds
    VERBOSE: 23:30:40 - Checking deployment status in 5 seconds
    VERBOSE: 23:30:46 - Resource Microsoft.VirtualMachineImages/imageTemplates 'aibWVDTemplate' provisioning status is running
    VERBOSE: 23:30:46 - Checking deployment status in 15 seconds
    VERBOSE: 23:31:02 - Checking deployment status in 16 seconds
    VERBOSE: 23:31:19 - Checking deployment status in 5 seconds
    VERBOSE: 23:31:25 - Resource Microsoft.VirtualMachineImages/imageTemplates 'aibWVDTemplate' provisioning status is succeeded
#>

## Check status of the new resource
#Get-AzResource -ResourceGroupName $imageResourceGroup -ResourceType $resourceType -ResourceName $resourceName


# Build the image, based on the template artifact
# azure CLI: az resource invoke-action --resource-group $imageResourceGroup --resource-type  Microsoft.VirtualMachineImages/imageTemplates -n helloImageTemplateWin01 --action Run 
Invoke-AzResourceAction -ResourceGroupName $imageResourceGroup -ResourceType $resourceType -ResourceName $resourceName -Action "Run" -ApiVersion $apiVersion -Force -Verbose | Tee-Object aibAction

#name                                 status     startTime
#----                                 ------     ---------
#54A0B4FD-692A-479C-8C31-B489619A8E57 InProgress 2019-08-20T11:33:00.224556Z

# wait approx 15mins

# Check status of image (created from AIB image template)
##Get-AzResource -ResourceGroupName $imageResourceGroup -ResourceType "Microsoft.Compute/images" -Name $imageName
#$winImage = Get-AzImage -ResourceGroupName $imageResourceGroup -ImageName $imageName

# Check image storage Profile OsDisk details (retrieve )
#$winImage.StorageProfile.OsDisk

# Logoff Azure session (without any output and session information)
Disconnect-AzAccount | Out-Null
