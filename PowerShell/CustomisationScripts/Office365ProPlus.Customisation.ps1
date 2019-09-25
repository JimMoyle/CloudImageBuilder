$path = "$env:programdata\AzureImageBuilder"

New-Item -ItemType Directory -Path "$path\Unzipped" -Force
New-Item -ItemType Directory -Path "$path\Logs" -Force
New-Item -ItemType Directory -Path "$path\Install" -Force

# download zip line
# "https://publicresources.blob.core.windows.net/downloads/Office365ProPlus.zip"

Expand-Archive -Path "$path\Install\Office365ProPlus.zip" -DestinationPath "$path\Unzipped" -Force

$cmdPath = "$path\Unzipped\Office365ProPlus\setup.exe"
$cmdArgList = \"/configure `\"C:\unzipped\Office365ProPlus\WVDconfiguration.xml`\"\"
Start-Process -FilePath $cmdPath -ArgumentList $cmdArgList -PassThru | Wait-Process -Timeout 1800 -ErrorAction SilentlyContinue