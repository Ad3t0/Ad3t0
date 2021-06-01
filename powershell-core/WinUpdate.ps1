while ($fileTempConf -ne "n" -and $fileTempConf -ne "y") {
    ""
    $fileTempConf = Read-Host "Install all Windows updates rebooting automatically untill all are complete? [y/n]"
}
if ($fileTempConf -eq "y") {
    $taskFile = @'
Import-Module PSWindowsUpdate
$updates = Get-WUInstall -AcceptAll -AutoReboot
Install-WindowsUpdate -AcceptAll -AutoReboot
if (!($updates)) {
    schtasks.exe /delete /tn WinUpdate /f
    Remove-Item -Path "C:\ProgramData\WinUpdate.ps1" -Force
}
shutdown /r /t 0
'@
    Set-Content "C:\ProgramData\WinUpdate.ps1" $taskFile
    $Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-file C:\ProgramData\WinUpdate.ps1"
    $Trigger = New-ScheduledTaskTrigger -AtStartup
    $Settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit 0
    $Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings
    Register-ScheduledTask -TaskName 'WinUpdate' -InputObject $Task -User SYSTEM
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module -Name PSWindowsUpdate -Confirm:$False -Force
    Import-Module PSWindowsUpdate
    $updates = Get-WUInstall -AcceptAll -AutoReboot
    Install-WindowsUpdate -AcceptAll -AutoReboot
    if (!($updates)) {
        schtasks.exe /delete /tn WinUpdate /f
        Remove-Item -Path "C:\ProgramData\WinUpdate.ps1" -Force
    }
    shutdown /r /t 0
}