# Settings
$msUpdateServiceID = "7971f918-a847-4430-9279-4a52d1efe18d"
$excludedUpdates = "'Teams', 'OneDrive'"
$updateCriteria = "isinstalled=0 and deploymentaction=*"

# Install required providers and modules
$null = Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
$null = Install-Module -Name PSWindowsUpdate -Force
Import-Module PSWindowsUpdate

# Wait for module to load
Start-Sleep -Seconds 5

# Add Microsoft Update Service
Add-WUServiceManager -ServiceID $msUpdateServiceID -AddServiceFlag 7 -Confirm:$false

# Install Windows Updates
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot -NotTitle $excludedUpdates -Criteria $updateCriteria