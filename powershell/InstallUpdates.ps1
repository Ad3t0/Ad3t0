Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name PSWindowsUpdate -Confirm:$False -Force
Import-Module PSWindowsUpdate
Start-Sleep 5
Add-WUServiceManager -MicrosoftUpdate -Confirm:$false
Start-Sleep 30
Get-WindowsUpdate -MicrosoftUpdate -Install -AcceptAll -AutoReboot -Verbose
