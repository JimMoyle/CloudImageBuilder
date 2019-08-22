<#
.Synopsis
   Create a Windows VM, using Azure Image Builder (Module Az)
.DESCRIPTION
   Create a Windows VM, using Azure Image Builder (Module Az)
.NOTES
   Author: Esther Barthel, MSc
   Version: 0.2
   Created: 2019-08-09
   Updated: 2019-08-22
            Fixed the not working cmdlet for the image template upload to the Azure Image Builder service, 
            thanks to Daniel Sol for providing the correct cmdlet and template file

   Research Links: https://docs.microsoft.com/en-us/powershell/azure/overview?view=azps-1.6.0
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

#region Subscription information
    # Get the tenantID from the session
    $tenantID = $AzSession.Context.Tenant.TenantId
    # Get SubscriptionID for the given TenantID
    $subscriptionID = (Get-AzSubscription -TenantId $TenantID).SubscriptionId
#endregion

Write-Verbose " * Creating a Custom Windows Managed Image w/ Azure Image Builder service - Template Artifact"

#region Set AIB Variables
    # Resource group name - we are using myImageBuilderRG in this example
    $imageResourceGroup="aibImageRG"
    # Region location 
    $location="WestUS2"
    # Run output name
    $runOutputName="aibWindows"
    # name of the image to be created
    $imageName="aibWinImage"
    # JSON template file
    $jsonTemplateFile = "C:\_GitHub\CloudImageBuilder\PowerShell\helloImageTemplateWin.json"
    # Type of the Azure Image Builder Image Template (resource)
    $resourceType = "Microsoft.VirtualMachineImages/ImageTemplates"
    # Name of the Azure Image Builder Image Template (resource)
    $resourceName = "helloImageTemplateWin01"
    #endregion

# Download the template file template (with placeholders) from Daniel Sol's github with Invoke-WebRequest cmdlet
# azure CLI: curl https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/quickquickstarts/0_Creating_a_Custom_Windows_Managed_Image/helloImageTemplateWin.json -o helloImageTemplateWin.json


# NOTE: We have a new template file (added a resouces section)!!!
#$templateUrl = "https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/quickquickstarts/0_Creating_a_Custom_Windows_Managed_Image/helloImageTemplateWin.json"
$templateUrl="https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/solutions/5_PowerShell_deployments/armTemplateWin.json"

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
#-$aibImageTemplate = New-AzResource -ResourceGroupName $imageResourceGroup -ResourceName $resourceName -ResourceType $resourceType -Properties $jsonConfigFile -IsFullObject -Verbose

$aibImageTemplate = New-AzResourceGroupDeployment -ResourceGroupName $imageResourceGroup -Name $resourceName -TemplateFile $jsonTemplateFile -TemplateParameterObject $objTemplateParameter -Verbose

# wait approx 1-3mins, depending on external links

<#
    VERBOSE: Performing the operation "Creating Deployment" on target "aibImageRG".
    VERBOSE: 15:47:45 - Template is valid.
    VERBOSE: 15:47:49 - Create template deployment 'helloImageTemplateWin01'
    VERBOSE: 15:47:49 - Checking deployment status in 5 seconds
    VERBOSE: 15:47:55 - Checking deployment status in 5 seconds
    VERBOSE: 15:48:01 - Resource Microsoft.VirtualMachineImages/imageTemplates 'helloImageTemplateWin01' provisioning status is running
    VERBOSE: 15:48:02 - Checking deployment status in 12 seconds
    VERBOSE: 15:48:15 - Checking deployment status in 5 seconds
    VERBOSE: 15:48:20 - Checking deployment status in 11 seconds
    VERBOSE: 15:48:32 - Checking deployment status in 5 seconds
    VERBOSE: 15:48:38 - Resource Microsoft.VirtualMachineImages/imageTemplates 'helloImageTemplateWin01' provisioning status is succeeded
#>

## Check status of the new resource
#Get-AzResource -ResourceGroupName $imageResourceGroup -ResourceType $resourceType -ResourceName $resourceName


# Build the image, based on the template artifact
# azure CLI: az resource invoke-action --resource-group $imageResourceGroup --resource-type  Microsoft.VirtualMachineImages/imageTemplates -n helloImageTemplateWin01 --action Run 
$aibAction = Invoke-AzResourceAction -ResourceGroupName $imageResourceGroup -ResourceType $resourceType -ResourceName $resourceName -Action "Run" -ApiVersion $apiVersion -Force

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
