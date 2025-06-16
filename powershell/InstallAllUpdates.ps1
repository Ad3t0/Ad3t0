Write-Host "This script will customize Windows 11 settings and unpin apps from the taskbar" -ForegroundColor Yellow
$confirmation = Read-Host "Continue? (Y/N)"
if ($confirmation -notin @('Y', 'y')) {
    Write-Host "Operation cancelled." -ForegroundColor Red
    exit
}

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name PSWindowsUpdate -Confirm:$False -Force
Import-Module PSWindowsUpdate
Start-Sleep 5
Add-WUServiceManager -MicrosoftUpdate -Confirm:$false
Start-Sleep 30
Get-WindowsUpdate -MicrosoftUpdate -Install -AcceptAll -IgnoreReboot -Verbose

$confirmation = $null
$confirmation = Read-Host "Reboot now? (Y/N)"
if ($confirmation -notin @('Y', 'y')) {
    exit
}
Write-Host "Rebooting in 10 seconds. Press CTRL+C to cancel..."
Start-Sleep 10
shutdown /t 0 /r