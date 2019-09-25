function Update-AibTemplate {
    [CmdletBinding()]

    Param (
        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [System.String]$TemplateUrl,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [System.String]$ApiVersion,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [System.String]$SubscriptionID,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [System.String]$ResourceGroupName,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [System.String]$Location,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [System.String]$ImageName,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [System.String]$RunOutputName,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [System.String]$PublisherName,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [System.String]$Offer,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [System.String]$ImageVersion,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [System.String]$Sku,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [System.String]$Type,
        
        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [int]$BuildTimeoutInMinutes = 100,

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$PathToCustomizationScripts
        
    )

    BEGIN {
        Set-StrictMode -Version Latest
    } # Begin
    PROCESS {

        #Grab json template, needs to be accessable, could change to unc path if you wanted
        try {
            $jsonTemplate = Invoke-WebRequest -Uri $TemplateUrl -UseBasicParsing -ErrorAction Stop
        }
        catch {
            Write-Error "Cannot connect to $TemplateUrl to download json template"
            exit
        }

        #image id needed for builder
        $imageId = "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.Compute/images/$ImageName"
        
        #You can create as many tags as you like here
        $tags = @{
            Source    = 'azVmImageBuilder'
            BaseOsImg = $Offer
            Sku       = $Sku
            Version   = $ImageVersion
        }

        #grab json file content getting rid of http stuff and convert to object
        $template = $jsonTemplate.Content | ConvertFrom-Json

        #Set tempate values
        $template.resources.properties.buildTimeoutInMinutes = $BuildTimeoutInMinutes
        $template.resources.properties.source.publisher = $PublisherName
        $template.resources.properties.source.offer = $Offer
        $template.resources.properties.source.sku = $Sku
        $template.resources.properties.source.version = $ImageVersion
        #distribute is an array with one object so need the [0]
        $template.resources.properties.distribute[0].type = $Type
        $template.resources.properties.distribute[0].imageId = $imageId
        $template.resources.properties.distribute[0].location = $Location
        $template.resources.properties.distribute[0].runOutputName = $RunOutputName
        $template.resources.properties.distribute[0].artifactTags = $tags

        if ($PathToCustomizationScripts) {

            $files = Get-ChildItem -Path $PathToCustomizationScripts -File

            foreach ($file in $files) {
                #Make sure it's a powershell file
                if ($file.Extension -ne '.ps1') {
                    Write-Warning 'Only PowerShell Scripts are currently supported in this script'
                    break
                }

                #Create customisation object with inline powershell script
                $customization = [PSCustomObject]@{
                    type   = 'PowerShell'
                    name   = $file.BaseName
                    inline = Get-Content -Path $file.FullName
                }

                #Add customisation to template
                $template.resources.properties.customize += $customization
            }
        }
        
        Write-Output $template

    } #Process
    END { } #End
}  #function Update-AibTemplate