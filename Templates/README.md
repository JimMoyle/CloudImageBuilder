Note: The new custom template CustomTemplateWVD.json is added to this folder for reference as the current PowerShell script downloads the template file from a publicly accessible Azure blob and replaces the placeholders for Resource Group, Subscription ID, Image Name, etc.

The custom template customizations are based on https://docs.microsoft.com/en-us/azure/virtual-desktop/install-office-on-wvd-master-image and the directives for the customization options that are being supported for Windows VMs (see https://docs.microsoft.com/en-us/azure/virtual-machines/linux/image-builder-json?toc=%2Fazure%2Fvirtual-machines%2Fwindows%2Ftoc.json#properties-customize)

Image Builder supports multiple ‘customizers’. Customizers are functions that are used to customize your image, such as running scripts, or rebooting servers.

When using customize:

- You can use multiple customizers, but they must have a unique name.
- Customizers execute in the order specified in the template.
- If one customizer fails, then the whole customization component will fail and report back an error.
- It is strongly advised you test the script thoroughly before using it in a template. Debugging the script on your own VM will be easier.
- Do not put sensitive data in the scripts.
- The script locations need to be publicly accessible, unless you are using MSI.

**Windows restart customizer**
The Restart customizer allows you to restart a Windows VM and wait for it come back online, this allows you to install software that requires a reboot.
OS Support: Windows
Customize properties:
- Type: WindowsRestart
- restartCommand - Command to execute the restart (optional). The default is 'shutdown /r /f /t 0 /c \"packer restart\"'.
- restartCheckCommand – Command to check if restart succeeded (optional).
- restartTimeout - Restart timeout specified as a string of magnitude and unit. For example, 5m (5 minutes) or 2h (2 hours). The default is: '5m'

**PowerShell customizer**
The shell customizer supports running PowerShell scripts and inline command, the scripts must be publicly accessible for the IB to access them.
OS support: Windows and Linux
Customize properties:
- type – PowerShell.
- scriptUri - URI to the location of the PowerShell script file.
- inline – Inline commands to be run, separated by commas.
- valid_exit_codes – Optional, valid codes that can be returned from the script/inline command, this will avoid reported failure of the script/inline command.

**File customizer**
The File customizer lets image builder download a file from a GitHub or Azure storage. If you have an image build pipeline that relies on build artifacts, you can then set the file customizer to download from the build share, and move the artifacts into the image.
OS support: Linux and Windows
File customizer properties:
- sourceUri - an accessible storage endpoint, this can be GitHub or Azure storage. You can only download one file, not an entire directory. If you need to download a directory, use a compressed file, then uncompress it using the Shell or PowerShell customizers.
- destination – this is the full destination path and file name. Any referenced path and subdirectories must exist, use the Shell or 

*Note: The file customizer is only suitable for small file downloads, < 20MB. For larger file downloads use a script or inline command, the use code to download files, such as, Linux wget or curl, Windows, Invoke-WebRequest.*

