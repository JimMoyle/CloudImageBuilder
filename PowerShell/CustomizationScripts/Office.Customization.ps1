$path = "$env:programdata\AzureImageBuilder"

New-Item -ItemType Directory -Path "$path\Unzipped" -Force
New-Item -ItemType Directory -Path "$path\Logs" -Force
New-Item -ItemType Directory -Path "$path\Install" -Force

# download zip line
Invoke-WebRequest -Uri "https://publicresources.blob.core.windows.net/downloads/Office365ProPlus.zip" -OutFile "$path\Install\Office365ProPlus.zip"

Expand-Archive -Path "$path\Install\Office365ProPlus.zip" -DestinationPath "$path\Unzipped" -Force

$cmdPath = "$path\Unzipped\Office365ProPlus\setup.exe"
$cmdArgList = "/configure `"$path\Unzipped\Office365ProPlus\WVDconfiguration.xml`""
Start-Process -FilePath $cmdPath -ArgumentList $cmdArgList -Wait -RedirectStandardError "$path\Logs\O365Error.log"ConvertTo-Hashtable.ps1