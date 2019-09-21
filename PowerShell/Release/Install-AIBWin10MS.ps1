function Install-AIBWin10MS {

    [CmdletBinding()]

    Param (
        [Parameter(
            Position = 1,
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [string]$Location,

        [Parameter(
            Position = 2,
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [Alias('Name')]
        [string]$ResourceGroupName,

        [Parameter(
            Position = 2,
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [Alias('Id')]
        [string]$subscriptionID,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true
        )]
        [System.Management.Automation.PSCredential]$Credential
    )

    BEGIN {
        #Requires -Modules 'Az.Compute', 'Az.Resources', 'Az.Accounts'
        Set-StrictMode -Version Latest
        if ($Credential) {
            $azSession = Connect-AzAccount -Credential $Credential
        }
        else{
            $azSession = Connect-AzAccount
        }
        $tenantID = $AzSession.Context.Tenant.TenantId
        if ((Get-AzSubscription -TenantId $TenantID).SubscriptionId -notcontains $subscriptionID ){
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
            Write-Error "pre-reqs not met for Azure Image Builder.  Check https://docs.microsoft.com/en-us/azure/virtual-machines/windows/image-builder for all pre-requisite steps"
            exit
        }

        New-AIBResourceGroup -Name $ResourceGroupName -Location $Location -SubscriptionID $subscriptionID -TenantID $tenantID | Out-Null
        
    } #Process
    END { } #End
}  #function Install-AIBWin10MS