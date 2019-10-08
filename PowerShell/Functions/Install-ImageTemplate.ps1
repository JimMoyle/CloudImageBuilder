function Install-ImageTemplate {
    [CmdletBinding()]

    Param (

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [System.String]$Location,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [System.String]$ResourceGroupName,

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$ResourceType = "Microsoft.VirtualMachineImages/ImageTemplates",

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$ResourceName = "aibWVDTemplate",

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [string]$TemplateFile
    )

    BEGIN {
        Set-StrictMode -Version Latest
    } # Begin
    PROCESS {   

        $templateParameterObject = @{
            "imageTemplateName" = $resourceName
            "api-version"       = $ApiVersion
            "svclocation"       = $Location
        }

        $paramsRGD = @{
            ResourceGroupName       = $ResourceGroupName
            Name                    = $ResourceName
            TemplateFile            = $TemplateFile
            TemplateParameterObject = $templateParameterObject
        }

        # submit the template to the Azure Image Builder Service 
        # (creates the image template artifact and stores dependent artifacts (scripts, etc) in the staging Resource Group IT_<resourcegroupname>_<temmplatename>)
        New-AzResourceGroupDeployment  @paramsRGD

        $paramsRA = @{
            ResourceGroupName = $ResourceGroupName 
            ResourceType      = $resourceType 
            ResourceName      = $resourceName 
            Action            = "Run" 
            ApiVersion        = $apiVersion 
            Force             = $true
        }

        # Build the image, based on the template artifact
        Invoke-AzResourceAction @paramsRA


    } #Process
    END { } #End
}  #function Install-ImageTemplate