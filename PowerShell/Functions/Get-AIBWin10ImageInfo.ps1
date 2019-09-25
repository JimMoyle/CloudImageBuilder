function Get-AIBWin10ImageInfo {
    [CmdletBinding()]

    Param (
        [Parameter(
            Position = 0,
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [System.String]$Location,

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$PublisherName = 'MicrosoftWindowsDesktop',

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$Offer = 'windows-10',

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$SkuMatchString = '*-evd'
    )

    BEGIN {
        Set-StrictMode -Version Latest
    } # Begin
    PROCESS {
        
        $commonParams = @{
            Location      = $Location 
            PublisherName = $PublisherName
        }

        $publisher = Get-AzVMImagePublisher -Location $Location

        if ($publisher.PublisherName -notcontains $publisherName) {
            Write-Error "Publisher list does not contain $publisherName"
            exit
        }

        $offerList = Get-AzVMImageOffer @commonParams

        if ($offerList.Offer -notcontains $Offer) {
            Write-Error "Offer list does not contain $Offer"
            exit
        }
        
        $sku = Get-AzVMImageSku @commonParams -Offer $Offer | Where-Object { $_.Skus -like $SkuMatchString }

        $newestImage = $sku | Get-AzVMImage | Sort-Object -Descending -Property Version | Select-Object -First 1

        $output = [PSCustomObject]@{
            Publisher = $publisherName
            Offer     = $Offer
            Sku       = $newestImage.Skus
            Version   = $newestImage.Version
        }

        Write-Output $output

    } #Process
    END { } #End
}  #function Get-AIBWin10ImageInfo