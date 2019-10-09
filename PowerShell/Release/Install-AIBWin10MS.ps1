function Install-AibWin10MS {

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
        [ValidateSet('ManagedImage', 'SharedImage')]
        [string]$OutputType = 'ManagedImage',

        [Parameter(
            Position = 4,
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [Alias('Id')]
        [string]$SubscriptionID,

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [string]$PathToCustomizationScripts,

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [string]$SharedImageGalleryName



    )

    BEGIN {
        Set-StrictMode -Version Latest

        #Requires -Modules 'Az.Compute', 'Az.Resources', 'Az.Accounts'

        #region get functions
        $Private = @( Get-ChildItem -Path $PSScriptRoot\..\functions\*.ps1 -ErrorAction SilentlyContinue )

        #Dot source the functions
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

        #Api Version will change once we are in GA, hopefully just to use the latest version
        $apiVersion = "2019-05-01-preview"

        $sharedImageDefName = 'Windows10MultiSession'

        if ($SharedImageGalleryName -and $OutputType -eq 'ManagedImage') {
            Write-Error -Message "Managed Images cannot be used with shared galleries, set OutputType to SharedImage to use a gallery"
            exit
        }

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

        if ($OutputType -eq 'SharedImage') {
            try {
                $paramUpdateSharedImageGallery = @{
                    #ErrorAction        = 'Stop'
                    SharedImageGalName = $SharedImageGalleryName
                    ResourceGroupName  = $Name
                    Location           = $Location
                    ImageDefName       = $sharedImageDefName
                    Publisher          = $imageInfo.Publisher
                    Offer              = $imageInfo.Offer
                    Sku                = $imageInfo.Sku
                }
                Update-SharedImageGallery @paramUpdateSharedImageGallery
            }
            catch {
                Write-Error "Could not validate or create Gallery $SharedImageGalleryName"
                exit
            }
        }

        $paramsUpdateAibTemplate = @{
            TemplateUrl                = "https://raw.githubusercontent.com/JimMoyle/CloudImageBuilder/master/Templates/GenericTemplate.json"
            ApiVersion                 = $apiVersion
            SubscriptionID             = $subscriptionID
            ResourceGroupName          = $Name
            Location                   = $Location
            ImageName                  = $Name + "MasterImage"
            RunOutputName              = $Name + "WindowsRun"
            PublisherName              = $imageInfo.Publisher
            Offer                      = $imageInfo.Offer
            ImageVersion               = $imageInfo.Version
            Type                       = $OutputType
            Sku                        = $imageInfo.Sku
            PathToCustomizationScripts = $PathToCustomizationScripts
            SharedImageGalName         = $SharedImageGalleryName
            ImageDefName              = $sharedImageDefName 
        }
        $template = Update-AibTemplate @paramsUpdateAibTemplate #| Out-Null

        $tempFile = New-TemporaryFile
        
        $template | Set-Content $tempfile

        $resourceName = $Name + "WVDTemplate"

        $paramsInstallImageTemplate = @{
            #ErrorAction        = 'Stop'
            Location          = $Location
            ResourceGroupName = $Name
            ResourceName      = $resourceName
            ResourceType      = "Microsoft.VirtualMachineImages/ImageTemplates"
            TemplateFile      = $tempFile
        }
        try{
            Install-ImageTemplate @paramsInstallImageTemplate #| Out-Null
        }
        catch{
            Write-Error "Could Not install Image Template"
            exit
        }

        Remove-Item $tempFile

        $runState = 'Running'

        while ($runState -eq 'Running' ) {
            Start-Sleep 5
            $status = Get-AibBuildStatus -ApiVersion $apiVersion -AzContext $azContext -ResourceGroupName $Name -ImageName $resourceName
            $runState = $status.runState
        }

        if ($runState -ne 'Succeeded') {
            Write-Error "Template deployment failed.  Please manually clean up resources"
            exit
        }

        $paramGetAzResource = @{
            ResourceName      = $resourceName
            ResourceGroupName = $Name 
            ResourceType      = 'Microsoft.VirtualMachineImages/imageTemplates' 
            ApiVersion        = $apiVersion
        }

        $resTemplateId = Get-AzResource @paramGetAzResource

        Remove-AzResource -ResourceId $resTemplateId.ResourceId -Force

        
    } #Process
    END { } #End
}  #function Install-AIBWin10MS
