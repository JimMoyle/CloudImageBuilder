<#
.Synopsis
   Find the Windows VM image properties in the Azure Marketplace, using Azure PowerShell (Module Az)
.DESCRIPTION
   Find the Windows VM image properties in the Azure Marketplace, using Azure PowerShell (Module Az)
   This script gives different examples to retrieve the available Windows VMs in the marketplace and their required image deployment information, 
   like location, publisher, offer, sku, and version (as is being used by the Azure Image Builder template)
.NOTES
   Author: Esther Barthel, MSc
   Version: 0.1
   Created: 2019-08-08
   Updated: 

   Research Links: https://docs.microsoft.com/en-us/powershell/azure/overview?view=azps-1.6.0
                   https://docs.microsoft.com/en-us/azure/virtual-machines/windows/cli-ps-findimage
#>

#region Config Variables
#endregion

#region Pre-check: Check if Module Az is installed
    Write-Output ""
    Write-Output "Pre-Check: Check if the Az Module is already installed: "
    If ($null -eq (Get-InstalledModule -Name Az -ErrorAction SilentlyContinue))
    {
        Write-Output " => Module Az is NOT installed"
        Break
    }
    Else
    {
        Write-Output " => Module Az is installed"
    }
#endregion

#login to Azure with account credentials to set this for the subscription (interactive logon)
$azSession = Connect-AzAccount

Write-Verbose " * Retrieve the VM attributes"

# List the publishers for Microsoft Windows, based on location
$locationName = "westeurope" 
Get-AzVMImagePublisher -Location $locationName | Select-Object PublisherName | Where-Object {$_.PublisherName -like "MicrosoftWindows*"}

<#
PublisherName                
-------------                
MicrosoftWindowsDesktop      
MicrosoftWindowsServer       
MicrosoftWindowsServerHPCPack
#>

# Check the offerings of a specific Microsoft Windows publisher
$locationName = "westeurope" 
$publisherName = "MicrosoftWindowsServer"
Get-AzVMImageOffer -Location $locationName -PublisherName $publisherName | Select-Object Offer

<#
Offer                                    
-----                                    
19h1gen2servertest                       
server2016gen2testing                    
servertesting                            
windows-10-1607-vhd-server-prod-stage    
windows-10-1803-vhd-server-prod-stage    
windows-10-1809-vhd-server-prod-stage    
windows-10-1903-vhd-server-prod-stage    
windows-7-0-sp1-vhd-server-prod-stage    
windows-8-0-vhd-server-prod-stage        
windows-8-1-vhd-server-prod-stage        
Windows-HUB                              
windows-server-2012-vhd-server-prod-stage
WindowsServer                            
windowsserver-gen2-testing               
windowsserver-gen2preview                
WindowsServerSemiAnnual                  
#>

# Check the offerings of a specific Microsoft Windows publisher
$locationName = "westeurope" 
$publisherName = "MicrosoftWindowsDesktop"
Get-AzVMImageOffer -Location $locationName -PublisherName $publisherName | Select-Object Offer

<#
Offer                                
-----                                
21e23361-881e-4f0e-a27c-c53241b20896 
676738ac-a807-468f-8a7b-961bfa3a3404 
6f8d5b91-ec98-4230-85d8-cc4e0a5c11ef 
office-365                           
Test-offer-legacy-id                 
Windows-10                           
windows-10-1607-vhd-client-prod-stage
windows-10-1803-vhd-client-prod-stage
windows-10-1809-vhd-client-prod-stage
windows-10-1903-vhd-client-prod-stage
windows-10-ppe                       
windows-7                            
windows-7-0-sp1-vhd-client-prod-stage
windows-evd                          
#>

# Check the skus for a specific offer (including publisher and location)
$locationName = "westeurope" 
$publisherName = "MicrosoftWindowsServer"
$offerName = "WindowsServer"
Get-AzVMImageSku -Location $locationName -PublisherName $publisherName -Offer $offerName | Select-Object Skus

<#
Skus                                          
----                                          
2008-R2-SP1                                   
2008-R2-SP1-smalldisk                         
2008-R2-SP1-zhcn                              
2012-Datacenter                               
2012-Datacenter-smalldisk                     
2012-Datacenter-zhcn                          
2012-R2-Datacenter                            
2012-R2-Datacenter-smalldisk                  
2012-R2-Datacenter-zhcn                       
2016-Datacenter                               
2016-Datacenter-Server-Core                   
2016-Datacenter-Server-Core-smalldisk         
2016-Datacenter-smalldisk                     
2016-Datacenter-with-Containers               
2016-Datacenter-with-RDSH                     
2016-Datacenter-zhcn                          
2019-Datacenter                               
2019-Datacenter-Core                          
2019-Datacenter-Core-smalldisk                
2019-Datacenter-Core-with-Containers          
2019-Datacenter-Core-with-Containers-smalldisk
2019-Datacenter-smalldisk                     
2019-Datacenter-with-Containers               
2019-Datacenter-with-Containers-smalldisk     
2019-Datacenter-zhcn                          
Datacenter-Core-1803-with-Containers-smalldisk
Datacenter-Core-1809-with-Containers-smalldisk
Datacenter-Core-1903-with-Containers-smalldisk
#>

# Check the skus for a specific offer (including publisher and location)
$locationName = "westeurope"
$publisherName = "MicrosoftWindowsDesktop"
$offerName = "windows-evd"
Get-AzVMImageSku -Location $locationName -PublisherName $publisherName -Offer $offerName | Select-Object Skus

<#
Skus             
----             
windows10-rs5-evd
#>

# Check the version for a specific sku (including offer, publisher and location)
$locationName = "westeurope"
$publisherName = "MicrosoftWindowsServer"
$offerName = "WindowsServer"
$skuName = "2019-Datacenter"
Get-AzVMImage -Location $locationName -PublisherName $publisherName -Offer $offerName -Skus $skuName | Select-Object Version

<#
Version             
-------             
17763.557.1907191810
17763.557.20190604  
17763.615.1907121548
2019.0.20181107     
2019.0.20181122     
2019.0.20181218     
2019.0.20190115     
2019.0.20190214     
2019.0.20190314     
2019.0.20190410     
2019.0.20190603     
#>


# Check the version for a specific sku (including offer, publisher and location)
$locationName = "westeurope"
$publisherName = "MicrosoftWindowsDesktop"
$offerName = "windows-evd"
$skuName = "windows10-rs5-evd"
Get-AzVMImage -Location $locationName -PublisherName $publisherName -Offer $offerName -Skus $skuName | Select-Object Version

<#
$null
#>

# Logoff Azure session (without any output and session information)
Disconnect-AzAccount | Out-Null
