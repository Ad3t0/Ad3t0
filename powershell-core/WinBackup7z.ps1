[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$logObj = [PSCustomObject]@{
    backupName            = $null
    backupSourcePath      = $null
    backupDestinationPath = $null
    backupRetention       = $null
    backupNewFullBackup   = $null
    backupCurrentCount    = 0
    backupTimeStamp       = $null
}

""
Write-Host "Current backup configurations"
Write-Host "-----------------------------"
$allBackups = Get-ChildItem "C:\ProgramData\WinBackup7z" | Where-Object Name -Like "WinBackup7z_*.json"

foreach ($backup in $allBackups) {

    $tempLogObj = Get-Content -Path $backup.VersionInfo.FileName -Raw | ConvertFrom-Json
    $tempLogObj | Format-Table

}
""
""



while ($null -eq $logObj.backupName -or $logObj.backupName -eq $tempLogObj.backupName) {
    $logObj.backupName = Read-Host "Enter name for backup"
}
""
while ($null -eq $logObj.backupSourcePath) {
    $logObj.backupSourcePath = Read-Host "Enter a source path to backup"
    if (!(Test-Path -Path $logObj.backupSourcePath)) {
        $logObj.backupSourcePath = $null
        Write-Warning "The path specified does not exist please try again"
        ""
    }
}


while ($null -eq $logObj.backupDestinationPath) {
    $logObj.backupDestinationPath = Read-Host "Enter a destination path to backup to"
}
if (!(Test-Path -Path "$($logObj.backupDestinationPath)\$($logObj.backupName)")) {
    New-Item -Path "$($logObj.backupDestinationPath)\$($logObj.backupName)" -ItemType "directory" -Force
}
$backupTime = Read-Host "Enter a time for backups to run, formatted like 3am for 3:00 AM"
$logObj.backupRetention = Read-Host "How many full backups to keep"



if (!(Test-Path -Path "C:\Program Files\7-Zip\7z.exe")) {
    $url = "https://www.7-zip.org/a/7z1900-x64.exe"
    $output = "$($env:TEMP)\7z1900-x64.exe"
    Invoke-WebRequest -Uri $url -OutFile $output
    ."$($env:TEMP)\7z1900-x64.exe" /S
    Wait-Process -Name 7z1900-x64
}
if (!(Test-Path -Path "C:\ProgramData\WinBackup7z")) {
    New-Item -Path "C:\ProgramData\WinBackup7z" -ItemType "directory"
}

$pathToJson = "C:\ProgramData\WinBackup7z\WinBackup7z_$($logObj.backupName).json"
$logObj | ConvertTo-Json | Set-Content $pathToJson
if (!(Test-Path -Path "C:\ProgramData\WinBackup7z\WinBackup7z.ps1")) {
    $taskFile = @'
$allBackups = Get-ChildItem "C:\ProgramData\WinBackup7z" | Where-Object Name -Like "WinBackup7z_*.json"
foreach ($backup in $allBackups) {
    $pathToJson = $backup.VersionInfo.FileName
    $logObj = Get-Content -Path $pathToJson -Raw | ConvertFrom-Json
    $backupCount = Get-ChildItem "$($logObj.backupDestinationPath)\$($logObj.backupName)" | Where-Object Name -Like "WinBackup7z_$($logObj.backupName)_*.7z"
    if ($backupCount.Count -gt [int]$logObj.backupRetention) {
        $purgeBackup = Get-ChildItem "$($logObj.backupDestinationPath)\$($logObj.backupName)" | Where-Object Name -Like "WinBackup7z_$($logObj.backupName)_*.7z" | Sort-Object LastWriteTime -Descending | Select-Object -Last 1
        Remove-Item $purgeBackup.VersionInfo.FileName
    }
    if ($logObj.backupNewFullBackup -eq $logObj.backupCurrentCount) {
        $logObj.backupTimeStamp = Get-Date -UFormat '+%Y-%m-%dT%H-%M-%S'
        ."C:\Program Files\7-Zip\7z.exe" a -t7z "$($logObj.backupDestinationPath)\$($logObj.backupName)\WinBackup7z_$($logObj.backupName)_$($logObj.backupTimeStamp).7z" $logObj.backupSourcePath -mx9
        $logObj.backupCurrentCount = 0
    }
    else {
        ."C:\Program Files\7-Zip\7z.exe" u -up0q3r2x2y2z1w2 "$($logObj.backupDestinationPath)\$($logObj.backupName)\WinBackup7z_$($logObj.backupName)_$($logObj.backupTimeStamp).7z" $logObj.backupSourcePath -mx9
        $logObj.backupCurrentCount++
    }
    $logObj | ConvertTo-Json | Set-Content $pathToJson
}
'@
    Set-Content "C:\ProgramData\WinBackup7z\WinBackup7z.ps1" $taskFile
    $Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoLogo -WindowStyle Hidden -ExecutionPolicy Bypass -File C:\ProgramData\WinBackup7z\WinBackup7z.ps1"
    $Trigger = New-ScheduledTaskTrigger -Daily -At $backupTime
    $Task = New-ScheduledTask -Action $Action -Trigger $Trigger
    Register-ScheduledTask -TaskName "WinBackup7z" -InputObject $Task -User SYSTEM
}