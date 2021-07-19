[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$logObj = [PSCustomObject]@{
    backupName = $null
    backupPath = $null
}





$logObj.backupName = Read-Host "Enter name for backup"





$pathToJson = "C:\ProgramData\WinBackup\WinBackup.json"

Set-Content $pathToJson $defaultSettings

$logObj | ConvertTo-Json | Set-Content $pathToJson





$timeScriptRun = Get-Date -UFormat '+%Y-%m-%dT%H-%M-%S'


if (!(Test-Path -Path "C:\Program Files\7-Zip\7z.exe")) {
    $url = "https://www.7-zip.org/a/7z1900-x64.exe"
    $output = "$($env:TEMP)\7z1900-x64.exe"
    Invoke-WebRequest -Uri $url -OutFile $output
    ."$($env:TEMP)\7z1900-x64.exe" /S
    Wait-Process -Name 7z1900-x64
}


if (!(Test-Path -Path "C:\ProgramData\WinUpdate")) {
    New-Item -Path "C:\ProgramData\WinUpdate" -ItemType "directory"
}




$taskFile = @'
    $pathToJson = "C:\ProgramData\WinUpdate\WinUpdate.json"
    $jsonSettings = Get-Content -Path $pathToJson -Raw | ConvertFrom-Json
    $jsonSettings.rebootCount = [int]$jsonSettings.rebootCount
Import-Module PSWindowsUpdate
$updates = Get-WUInstall -AcceptAll -AutoReboot -SendHistory | Format-List | Out-String | Add-Content "C:\ProgramData\WinUpdate\$($timeScriptRun).txt"
Install-WindowsUpdate -AcceptAll -AutoReboot -SendHistory | Format-List | Out-String |  Add-Content "C:\ProgramData\WinUpdate\$($timeScriptRun).txt"
if (!($updates) -or $jsonSettings.rebootCount -ge 6) {
    schtasks.exe /delete /tn WinUpdate /f
    Remove-Item -Path "C:\ProgramData\WinUpdate\WinUpdate.ps1" -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticecaption" -Value ""
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticetext" -Value ""
}
$jsonSettings.rebootCount = $jsonSettings.rebootCount + 1
$jsonSettings | ConvertTo-Json | Set-Content $pathToJson
shutdown /r /t 0 /f
'@
Set-Content "C:\ProgramData\WinUpdate\WinUpdate.ps1" $taskFile



$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoLogo -WindowStyle Hidden -ExecutionPolicy Bypass -File C:\ProgramData\WinUpdate\WinUpdate.ps1"
$Trigger = New-ScheduledTaskTrigger -AtStartup
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger
Register-ScheduledTask -TaskName 'WinUpdate' -InputObject $Task -User SYSTEM




