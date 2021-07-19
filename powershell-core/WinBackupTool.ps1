[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Clear-Host
""
Write-Host "1 - Install Chocolatey and basic dependencies and utilities"
Write-Host "2 - Remove all Windows temp files, run drive cleanup and remove old Windows versions"
Write-Host "3 - Install all Windows updates and reboot automatically untill all are complete"
Write-Host "4 - Auto reboot without warning (CAUTION)"
""
while ($functionsToRun -notlike "*1*" -and $functionsToRun -notlike "*2*" -and $functionsToRun -notlike "*3*" -and $functionsToRun -notlike "*4*") {
    $functionsToRun = Read-Host "Enter one or more functions to run [1/2/3/4]"
    $functionsToRun = $functionsToRun.ToString()
}
$timeScriptRun = Get-Date -UFormat '+%Y-%m-%dT%H-%M-%S'





if (!(Test-Path -Path "C:\ProgramData\WinUpdate")) {
    New-Item -Path "C:\ProgramData\WinUpdate" -ItemType "directory"
}
$pathToJson = "C:\ProgramData\WinUpdate\WinUpdate.json"
$defaultSettings = @"
{
"rebootCount":  0
}
"@
Set-Content $pathToJson $defaultSettings



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




