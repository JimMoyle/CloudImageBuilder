function New-AIBResourceGroup {
    [CmdletBinding()]

    Param (

        [Parameter(
            Position = 0,
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [System.String]$Name,

        [Parameter(
            Position = 1,
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [System.String]$Location,

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$AzureImageBuilderAppID = "cf32a0cc-373c-47c9-9156-0db11f6a6dfc",

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$TenantID,

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$SubscriptionID

    )

    BEGIN {
        Set-StrictMode -Version Latest
    } # Begin
    PROCESS {

        New-AzResourceGroup -Name $Name -Location $Location
        
        $paramNewAzRoleAssignment = @{
            ApplicationId      = $AzureImageBuilderAppID
            RoleDefinitionName = 'Contributor' 
            Scope              = "/subscriptions/$SubscriptionID/resourceGroups/$Name"
        }

        New-AzRoleAssignment @paramNewAzRoleAssignment
       
    } #Process
    END { } #End
}  #function New-AIBResourceGroup