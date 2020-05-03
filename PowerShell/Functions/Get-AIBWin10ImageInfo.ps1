function Get-AibWin10ImageInfo {
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

        # Check the offerings of a specific Microsoft Windows publisher
        $publisher = Get-AzVMImagePublisher -Location $Location

        if ($publisher.PublisherName -notcontains $publisherName) {
            Write-Error "Publisher list does not contain $publisherName"
            return
        }

        # Check the skus for a specific offer (including publisher and location)
        $offerList = Get-AzVMImageOffer @commonParams

        if ($offerList.Offer -notcontains $Offer) {
            Write-Error "Offer list does not contain $Offer"
            return
        }

        # Check the skus for a specific offer (including publisher and location)
        $sku = Get-AzVMImageSku @commonParams -Offer $Offer | Where-Object { $_.Skus -like $SkuMatchString }

        # Check the version for a specific sku (including offer, publisher and location) and select the newest one
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