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
        [System.Object]$Template
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
            TemplateObject          = $Template
            TemplateParameterObject = $templateParameterObject
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