while ($fileTempConf -ne "n" -and $fileTempConf -ne "y") {
    ""
    $fileTempConf = Read-Host "Install all Windows updates rebooting automatically untill all are complete? [y/n]"
}
if ($fileTempConf -eq "y") {
    New-Item -Path HKCU:\SOFTWARE\Ad3t0
    New-ItemProperty -Path HKCU:\SOFTWARE\Ad3t0 -Name RebootCount -Value 1
    Set-ItemProperty -Path HKCU:\SOFTWARE\Ad3t0 -Name RebootCount -Value 1
    $taskFile = @'
Import-Module PSWindowsUpdate
$updates = Get-WUInstall -AcceptAll -AutoReboot
Install-WindowsUpdate -AcceptAll -AutoReboot
$rebootCount = Get-ItemProperty -Path HKCU:\SOFTWARE\Ad3t0 -Name RebootCount
if (!($updates) -or $rebootCount.RebootCount -ge 5) {
    schtasks.exe /delete /tn WinUpdate /f
    Remove-Item -Path "C:\ProgramData\WinUpdate.ps1" -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticecaption" -Value ""
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticetext" -Value ""
}
Set-ItemProperty -Path HKCU:\SOFTWARE\3form -Name RebootCount -Value ($rebootCount.RebootCount + 1)
shutdown /r /t 0 /f
'@
    Set-Content "C:\ProgramData\WinUpdate.ps1" $taskFile
    $Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoLogo -WindowStyle hidden -file C:\ProgramData\WinUpdate.ps1"
    $Trigger = New-ScheduledTaskTrigger -AtStartup
    $Task = New-ScheduledTask -Action $Action -Trigger $Trigger
    Register-ScheduledTask -TaskName 'WinUpdate' -InputObject $Task -User SYSTEM
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module -Name PSWindowsUpdate -Confirm:$False -Force
    Import-Module PSWindowsUpdate
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticecaption" -Value "Updates In Progress"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticetext" -Value "Updates are still running and the system may periodically reboot. Please wait..."
    $updates = Get-WUInstall -AcceptAll -AutoReboot
    Install-WindowsUpdate -AcceptAll -AutoReboot
    if (!($updates)) {
        schtasks.exe /delete /tn WinUpdate /f
        Remove-Item -Path "C:\ProgramData\WinUpdate.ps1" -Force
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticecaption" -Value ""
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticetext" -Value ""
    }
    shutdown /r /t 0 /f
}