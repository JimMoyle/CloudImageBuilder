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
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [System.String]$RunOutputName,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [System.String]$ImageName,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [System.String]$SubscriptionId,

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$ResourceType = "Microsoft.VirtualMachineImages/ImageTemplates",

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$ResourceName = "aibWVDTemplate",

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$ApiVersion = "2019-05-01-preview",

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$TemplateUrl = "https://publicresources.blob.core.windows.net/downloads/CustomTemplateWVD.json"
    )

    BEGIN {
        Set-StrictMode -Version Latest
    } # Begin
    PROCESS {   

        $objTemplateParameter = @{
            "imageTemplateName" = $resourceName
            "api-version"       = $ApiVersion
            "svclocation"       = $Location
        }

        $paramsRGD = @{
            ResourceGroupName       = $ResourceGroupName
            Name                    = $ResourceName
            TemplateFile            = $jsonTemplateFile
            TemplateParameterObject = $objTemplateParameter
        }

        New-AzResourceGroupDeployment  @paramsRGD

        $paramsRA = @{
            ResourceGroupName = $ResourceGroupName 
            ResourceType      = $resourceType 
            ResourceName      = $resourceName 
            Action            = "Run" 
            ApiVersion        = $apiVersion 
            Force             = $true
        }

        Invoke-AzResourceAction @paramsRA


    } #Process
    END { } #End
}  #function Install-ImageTemplate