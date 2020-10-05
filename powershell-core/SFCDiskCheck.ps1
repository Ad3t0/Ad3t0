if (!([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544"))) {
    Write-Warning "Powershell is not running as Administrator. Exiting..."
    Start-Sleep 3
    Return
}
""
Write-Host "Image cleanup..." -ForegroundColor Yellow
DISM.exe /Online /Cleanup-image /Restorehealth
""
Write-Host "System file check and repair..." -ForegroundColor Yellow
""
Start-Sleep 5
sfc /scannow
""
Write-Host "chkdsk on next rebooot..." -ForegroundColor Yellow
""
Start-Sleep 5
chkdsk C: /f /r
while ($rebootConfirm -ne "n" -and $rebootConfirm -ne "y") {
	$rebootConfirm = Read-Host "Reboot now? [y/n]"
}
if ($rebootConfirm -eq "y") {
	Restart-Computer
}