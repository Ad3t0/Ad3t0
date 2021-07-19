[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$logObj = [PSCustomObject]@{
    backupName            = $null
    backupSourcePath      = $null
    backupDestinationPath = $null
    backupTime            = $null
    backupRetention       = $null
}
$logObj.backupName = Read-Host "Enter name for backup"
$logObj.backupSourcePath = Read-Host "Enter a source path to backup"
$logObj.backupDestinationPath = Read-Host "Enter a destination path to backup to"
$logObj.backupTime = Read-Host "Enter a time to backup, formatted like 3am for 3:00 AM"
$logObj.backupRetention = Read-Host "How many backups to keep"
if (!(Test-Path -Path "C:\Program Files\7-Zip\7z.exe")) {
    $url = "https://www.7-zip.org/a/7z1900-x64.exe"
    $output = "$($env:TEMP)\7z1900-x64.exe"
    Invoke-WebRequest -Uri $url -OutFile $output
    ."$($env:TEMP)\7z1900-x64.exe" /S
    Wait-Process -Name 7z1900-x64
}
if (!(Test-Path -Path "C:\ProgramData\WinBackup")) {
    New-Item -Path "C:\ProgramData\WinBackup" -ItemType "directory"
}
if (!(Test-Path -Path "$($logObj.backupDestinationPath)\$($logObj.backupName)")) {
    New-Item -Path "$($logObj.backupDestinationPath)\$($logObj.backupName)" -ItemType "directory" -Force
}
$pathToJson = "C:\ProgramData\WinBackup\WinBackup_$($logObj.backupName).json"
$logObj | ConvertTo-Json | Set-Content $pathToJson
$taskFile = @'
param ($backupName)
$pathToJson = "C:\ProgramData\WinBackup\WinBackup_$($backupName).json"
$logObj = Get-Content -Path $pathToJson -Raw | ConvertFrom-Json
$timeScriptRun = Get-Date -UFormat '+%Y-%m-%dT%H-%M-%S'
$backupCount = Get-ChildItem "$($logObj.backupDestinationPath)\$($logObj.backupName)" | Where-Object Name -Like "WinBackup_$($backupName)_*.7z"
if ($backupCount.Count -gt [int]$logObj.backupRetention) {
    $purgeBackup = Get-ChildItem "$($logObj.backupDestinationPath)\$($logObj.backupName)" | Where-Object Name -Like "WinBackup_$($backupName)_*.7z" | Sort-Object LastWriteTime -Descending | Select-Object -Last 1
    Remove-Item $purgeBackup.VersionInfo.FileName
}
."C:\Program Files\7-Zip\7z.exe" a -t7z "$($logObj.backupDestinationPath)\$($logObj.backupName)\WinBackup_$($logObj.backupName)_$($timeScriptRun).7z" $logObj.backupSourcePath -mx9
'@
Set-Content "C:\ProgramData\WinBackup\WinBackup_$($logObj.backupName).ps1" $taskFile
$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoLogo -WindowStyle Hidden -ExecutionPolicy Bypass -File C:\ProgramData\WinBackup\WinBackup_$($logObj.backupName).ps1 -backupName $($logObj.backupName)"
$Trigger = New-ScheduledTaskTrigger -Daily -At $logObj.backupTime
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger
Register-ScheduledTask -TaskName "WinBackup_$($logObj.backupName)" -InputObject $Task -User SYSTEM
