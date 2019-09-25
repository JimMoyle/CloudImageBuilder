function Install-AIBWin10MS {

    [CmdletBinding()]

    Param (
        
        [Parameter(
            Position = 1,
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [string]$Name,

        [Parameter(
            Position = 2,
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [string]$Location,

        [Parameter(
            Position = 3,
            ValuefromPipelineByPropertyName = $true
        )]
        [string]$OutputType = 'ManagedImage',

        [Parameter(
            Position = 3,
            ValuefromPipelineByPropertyName = $true
        )]
        [string]$PathToCustomizationScripts,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [Alias('Id')]
        [string]$SubscriptionID

    )

    BEGIN {
        #Requires -Modules 'Az.Compute', 'Az.Resources', 'Az.Accounts'

        Set-StrictMode -Version Latest

        $azContext = Get-AzContext

        if ($azContext.Subscription.Id -ne $SubscriptionID) {
            Write-Error "Can not find Subscription ID $SubscriptionID in current Azure context, Use Connect-AzAccout or Select-AzContext to correct this."
            exit
        }

        $tenantID = $azContext.Subscription.TenantId
        if ((Get-AzSubscription -TenantId $TenantID).SubscriptionId -notcontains $subscriptionID ) {
            Write-Error "Cannot find subscrioption Id $subscriptionID in tenant"
            exit
        }

        $apiVersion = "2019-05-01-preview"
        #region get functions
        $Private = @( Get-ChildItem -Path $PSScriptRoot\..\functions\*.ps1 -ErrorAction SilentlyContinue )

        #Dot source the files
        Foreach ($import in $Private) {
            Try {
                Write-Verbose "Importing $($Import.FullName)"
                . $import.fullname
            }
            Catch {
                Write-Error -Message "Failed to import function $($import.fullname): $_"
            }
        }
        #endregion
    } # Begin
    PROCESS {

        $imageInfo = Get-AIBWin10ImageInfo -Location $Location

        $aibProvider = Get-AzProviderFeature -ProviderNamespace Microsoft.VirtualMachineImages -FeatureName VirtualMachineTemplatePreview

        if ($aibProvider.RegistrationState -ne 'Registered') {
            Write-Error "pre-reqs not met for Azure Image Builder. Check https://docs.microsoft.com/en-us/azure/virtual-machines/windows/image-builder for all pre-requisite steps"
            exit
        }

        $paramNewAIBResourceGroup = @{
            Name           = $Name
            Location       = $Location
            SubscriptionID = $subscriptionID
            TenantID       = $tenantID
        }
        New-AIBResourceGroup @paramNewAIBResourceGroup #| Out-Null

        $paramsUpdateAibTemplate = @{
            TemplateUrl                = "https://publicresources.blob.core.windows.net/downloads/CustomTemplateWVD.json"
            ApiVersion                 = $apiVersion
            SubscriptionID             = $subscriptionID
            ResourceGroupName          = $Name
            Location                   = $Location
            ImageName                  = $Name + "GoldenImage"
            RunOutputName              = $Name + "WindowsRun"
            PublisherName              = $imageInfo.Publisher
            Offer                      = $imageInfo.Offer
            ImageVersion               = $imageInfo.Version
            Type                       = $OutputType
            Sku                        = $imageInfo.Sku
            PathToCustomizationScripts = $PathToCustomizationScripts
        }
        $template = Update-AibTemplate @paramsUpdateAibTemplate

        $paramsInstallImageTemplate = @{
            Location          = $Location
            ResourceGroupName = $Name
            SubscriptionID    = $subscriptionID
            RunOutputName     = $Name + "Windows"
            ImageName         = $Name + "GoldenImage"
            ResourceName      = $Name + "WVDTemplate"
            ApiVersion        = $apiVersion
            TemplateUrl       = "https://publicresources.blob.core.windows.net/downloads/CustomTemplateWVD.json"
            ResourceType      = "Microsoft.VirtualMachineImages/ImageTemplates"
        }
        Install-ImageTemplate @paramsInstallImageTemplate
        
    } #Process
    END { } #End
}  #function Install-AIBWin10MS
