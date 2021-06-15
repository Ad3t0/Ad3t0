while ($fileTempConf -ne "n" -and $fileTempConf -ne "y") {
    ""
    $fileTempConf = Read-Host "Install all Windows updates rebooting automatically untill all are complete? [y/n]"
}
if ($fileTempConf -eq "y") {
    if (!(Test-Path -Path "C:\ProgramData\ad3t0")) {
        New-Item -Path "C:\ProgramData\ad3t0" -ItemType "directory"
    }
    $pathToJson = "C:\ProgramData\ad3t0\WinUpdate.json"
    $defaultSettings = @"
{
    "rebootCount":  0
}
"@
    New-Item $pathToJson
    Set-Content $pathToJson $defaultSettings
    $taskFile = @'
    $pathToJson = "C:\ProgramData\ad3t0\WinUpdate.json"
    $jsonSettings = Get-Content -Path $pathToJson -Raw | ConvertFrom-Json
    $jsonSettings.rebootCount = [int]$jsonSettings.rebootCount
Import-Module PSWindowsUpdate
$updates = Get-WUInstall -AcceptAll -AutoReboot
Install-WindowsUpdate -AcceptAll -AutoReboot
if (!($updates) -or $jsonSettings.rebootCount -ge 5) {
    schtasks.exe /delete /tn WinUpdate /f
    Remove-Item -Path "C:\ProgramData\WinUpdate.ps1" -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticecaption" -Value ""
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticetext" -Value ""
}
$jsonSettings.rebootCount = $jsonSettings.rebootCount + 1
$jsonSettings | ConvertTo-Json | Set-Content $pathToJson
shutdown /r /t 0 /f
'@
    Set-Content "C:\ProgramData\WinUpdate.ps1" $taskFile
    $Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoLogo -WindowStyle Hidden -ExecutionPolicy Bypass -File C:\ProgramData\WinUpdate.ps1"
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