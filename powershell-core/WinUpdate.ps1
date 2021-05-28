Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name PSWindowsUpdate -Confirm:$False -Force
Import-Module PSWindowsUpdate
Get-WUInstall -AcceptAll –AutoReboot
Install-WindowsUpdate -AcceptAll -AutoReboot