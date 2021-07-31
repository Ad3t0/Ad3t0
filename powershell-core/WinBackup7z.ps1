[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$logObj = [PSCustomObject]@{
    backupName              = $null
    backupSourcePath        = $null
    backupDestinationPath   = $null
    backupFullBackupsToKeep = $null
    backupDaysBeforeFull    = $null
    backupCurrentCount      = 0
    backupTimeStamp         = $null
    backupFirst             = $True
}
$backupTime = $null
""
$tempLogObjAll = [System.Collections.ArrayList]::new()
$allBackups = Get-ChildItem "C:\ProgramData\WinBackup7z" -ErrorAction SilentlyContinue | Where-Object Name -Like "WinBackup7z_*.json" -ErrorAction SilentlyContinue
if ($allBackups) {
    Write-Host "Current backup configurations"
    Write-Host "-----------------------------"
    foreach ($backup in $allBackups) {
        $tempLogObj = Get-Content -Path $backup.VersionInfo.FileName -Raw | ConvertFrom-Json
        $tempLogObj | Select-Object backupName, backupSourcePath, backupDestinationPath, backupFullBackupsToKeep, backupCurrentCount | Format-Table
        [void]$tempLogObjAll.Add($tempLogObj)
    }
    ""
    ""
}
while ($null -eq $logObj.backupName) {
    $logObj.backupName = Read-Host "Enter name for backup"
}
$backupExists = $tempLogObjAll.backupName | Where-Object { $_ -eq $logObj.backupName }
if ($logObj.backupName -eq $backupExists) {
    Write-Warning "Editing current backup named $($logObj.backupName) type DELETE as source path to remove its configuration"
}
""
while ($null -eq $logObj.backupSourcePath -or $logObj.backupSourcePath -eq "DELETE") {
    $logObj.backupSourcePath = Read-Host "Enter a source path to backup"
    if ($logObj.backupSourcePath -eq "DELETE") {
        $logObj.backupName
        Remove-Item -Path "C:\ProgramData\WinBackup7z\WinBackup7z_$($logObj.backupName).json"
        exit
    }
    if (!(Test-Path -Path $logObj.backupSourcePath)) {
        $logObj.backupSourcePath = $null
        Write-Warning "The path specified does not exist please try again"
        ""
    }
}
while ($null -eq $logObj.backupDestinationPath) {
    $logObj.backupDestinationPath = Read-Host "Enter a destination path to backup to"
}
""
if (!(Test-Path -Path "$($logObj.backupDestinationPath)\$($logObj.backupName)")) {
    New-Item -Path "$($logObj.backupDestinationPath)\$($logObj.backupName)" -ItemType "directory" -Force
}
while ($backupTime -notmatch "\d\wm") {
    $backupTime = Read-Host "Enter a time for backups to run, formatted like 3am for 3:00 AM"
}
""
while ($logObj.backupDaysBeforeFull -isnot [int]) {
    $logObj.backupDaysBeforeFull = Read-Host "How many days until a new full backup point"
    $logObj.backupDaysBeforeFull = [int]$logObj.backupDaysBeforeFull
}
""
while ($logObj.backupFullBackupsToKeep -isnot [int]) {
    $logObj.backupFullBackupsToKeep = Read-Host "How many full backups to keep"
    $logObj.backupFullBackupsToKeep = [int]$logObj.backupFullBackupsToKeep
}
""
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
$taskFile = @'
$allBackups = Get-ChildItem "C:\ProgramData\WinBackup7z" | Where-Object Name -Like "WinBackup7z_*.json"
foreach ($backup in $allBackups) {
    $pathToJson = $backup.VersionInfo.FileName
    $logObj = Get-Content -Path $pathToJson -Raw | ConvertFrom-Json
    $backupCount = Get-ChildItem "$($logObj.backupDestinationPath)\$($logObj.backupName)" | Where-Object Name -Like "WinBackup7z_$($logObj.backupName)_*.7z"
    if ([int]$logObj.backupDaysBeforeFull -eq [int]$logObj.backupCurrentCount -or $logObj.backupCurrentCount -eq 0 -or $logObj.backupFirst -eq $True) {
        $logObj.backupFirst = $False
        $logObj.backupTimeStamp = Get-Date -UFormat '+%Y-%m-%dT%H-%M-%S'
        ."C:\Program Files\7-Zip\7z.exe" a -t7z "$($logObj.backupDestinationPath)\$($logObj.backupName)\WinBackup7z_$($logObj.backupName)_$($logObj.backupTimeStamp).7z" $logObj.backupSourcePath -mx9
        $logObj.backupCurrentCount = 0
        if ($backupCount.Count -eq $logObj.backupFullBackupsToKeep) {
            $purgeBackup = Get-ChildItem "$($logObj.backupDestinationPath)\$($logObj.backupName)" | Where-Object Name -Like "WinBackup7z_$($logObj.backupName)_*.7z" | Sort-Object LastWriteTime -Descending | Select-Object -Last 1
            Remove-Item $purgeBackup.VersionInfo.FileName
        }
    }
    else {
        ."C:\Program Files\7-Zip\7z.exe" u -up0q3r2x2y2z1w2 "$($logObj.backupDestinationPath)\$($logObj.backupName)\WinBackup7z_$($logObj.backupName)_$($logObj.backupTimeStamp).7z" $logObj.backupSourcePath -mx9
    }
    $logObj.backupCurrentCount++
    $logObj | ConvertTo-Json | Set-Content $pathToJson
}
'@
Set-Content "C:\ProgramData\WinBackup7z\WinBackup7z.ps1" $taskFile
Unregister-ScheduledTask -TaskName "WinBackup7z" -Confirm:$False -ErrorAction SilentlyContinue
Start-Sleep 1
$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoLogo -WindowStyle Hidden -ExecutionPolicy Bypass -File C:\ProgramData\WinBackup7z\WinBackup7z.ps1"
$Settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit 0 -AllowStartIfOnBatteries
$Trigger = New-ScheduledTaskTrigger -Daily -At $backupTime
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings
Register-ScheduledTask -TaskName "WinBackup7z" -InputObject $Task -User SYSTEM
