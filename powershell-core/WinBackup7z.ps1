[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$backupSettings = [PSCustomObject]@{
    backupName              = $null
    backupSourcePath        = $null
    backupDestinationPath   = $null
    backupFullBackupsToKeep = $null
    backupDaysBeforeFull    = $null
    backupCurrentCount      = 0
    backupTimeStamp         = $null
    backupFirst             = $True
}
""
$tempBackupSettingsAll = [System.Collections.ArrayList]::new()
$allBackups = Get-ChildItem "C:\ProgramData\WinBackup7z" -ErrorAction SilentlyContinue | Where-Object Name -Like "WinBackup7z_*.json" -ErrorAction SilentlyContinue
if ($allBackups) {
    Write-Host "Current backup configurations"
    Write-Host "-----------------------------"
    foreach ($backup in $allBackups) {
        $tempBackupSettings = Get-Content -Path $backup.VersionInfo.FileName -Raw | ConvertFrom-Json
        $tempBackupSettings | Select-Object backupName, backupSourcePath, backupDestinationPath, backupFullBackupsToKeep, backupCurrentCount | Format-Table
        [void]$tempBackupSettingsAll.Add($tempBackupSettings)
    }
    ""
    ""
}
while ($null -eq $backupSettings.backupName) {
    $backupSettings.backupName = Read-Host "Enter name for backup"
}
$backupExists = $tempBackupSettingsAll.backupName | Where-Object { $_ -eq $backupSettings.backupName }
if ($backupSettings.backupName -eq $backupExists) {
    Write-Warning "Editing current backup named $($backupSettings.backupName) type DELETE as source path to remove its configuration"
}
""
while ($null -eq $backupSettings.backupSourcePath -or $backupSettings.backupSourcePath -eq "DELETE") {
    $backupSettings.backupSourcePath = Read-Host "Enter a source path to backup"
    if ($backupSettings.backupSourcePath -eq "DELETE") {
        $backupSettings.backupName
        Remove-Item -Path "C:\ProgramData\WinBackup7z\WinBackup7z_$($backupSettings.backupName).json"
        exit
    }
    if (!(Test-Path -Path $backupSettings.backupSourcePath)) {
        $backupSettings.backupSourcePath = $null
        Write-Warning "The path specified does not exist please try again"
        ""
    }
}
""
while ($null -eq $backupSettings.backupDestinationPath) {
    $backupSettings.backupDestinationPath = Read-Host "Enter a destination path to backup to"
}
""
if (!(Test-Path -Path "$($backupSettings.backupDestinationPath)\$($backupSettings.backupName)")) {
    New-Item -Path "$($backupSettings.backupDestinationPath)\$($backupSettings.backupName)" -ItemType "directory" -Force
}
while ($backupSettings.backupDaysBeforeFull -isnot [int]) {
    ""
    $backupSettings.backupDaysBeforeFull = Read-Host "How many days until a new full backup point"
    $backupSettings.backupDaysBeforeFull = [int]$backupSettings.backupDaysBeforeFull
}
while ($backupSettings.backupFullBackupsToKeep -isnot [int]) {
    ""
    $backupSettings.backupFullBackupsToKeep = Read-Host "How many full backups to keep"
    $backupSettings.backupFullBackupsToKeep = [int]$backupSettings.backupFullBackupsToKeep
}
$scheduledTaskExists = Get-ScheduledTask -TaskName "WinBackup7z" -ErrorAction SilentlyContinue
if ($scheduledTaskExists.TaskName -ne "WinBackup7z") {
    ""
    while ($backupTime -notmatch "\d\wm") {
        $backupTime = Read-Host "Enter a time for backups to run, formatted like 3am for 3:00 AM"
    }
    ""
    while (!($verifiedCreds)) {
        $username = Read-Host "Enter the domain\user for the task to run as"
        if ($username -eq "SYSTEM") {
            ""
            Write-Host "Creating task as system, network file shares will not work" -ForegroundColor Green
            ""
            $verifiedCreds = $true
        }
        else {
            ""
            $password = Read-Host "Enter the password for the task user"
            $computer = $env:COMPUTERNAME
            Add-Type -AssemblyName System.DirectoryServices.AccountManagement
            $obj = New-Object System.DirectoryServices.AccountManagement.PrincipalContext ('machine', $computer)
            $goodCreds = $obj.ValidateCredentials($username, $password)
            if ($goodCreds) {
                ""
                Write-Host "Credentials validated successfully" -ForegroundColor Green
                ""
                $verifiedCreds = $true
            }
            else {
                ""
                Write-Warning "Credentials failed to validate try again"
                ""
            }
        }
    }
    ""
    Start-Sleep 1
    $Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoLogo -WindowStyle Hidden -ExecutionPolicy Bypass -File C:\ProgramData\WinBackup7z\WinBackup7z.ps1"
    $Settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit 0 -AllowStartIfOnBatteries
    $Trigger = New-ScheduledTaskTrigger -Daily -At $backupTime
    $Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings
    if ($username -eq "SYSTEM") {
        Register-ScheduledTask -TaskName 'WinBackup7z' -InputObject $Task -User SYSTEM
    }
    else {
        Register-ScheduledTask -TaskName 'WinBackup7z' -InputObject $Task -User $username -Password $password
    }
    ""
    Write-Host "Scheduled task was created" -ForegroundColor Green
}
if (!(Test-Path -Path "C:\ProgramData\WinBackup7z\WinBackup7z.json")) {
    while ($setupSMTP -ne "n" -and $setupSMTP -ne "y") {
        ""
        $setupSMTP = Read-Host "Configure SMTP backup alerts? [y/n]"
    }
    if ($setupSMTP -eq "y") {
        $smtpSettings = [PSCustomObject]@{
            smtpServer   = $null
            smtpPort     = $null
            smtpUser     = $null
            smtpPassword = $null
            smtpSSL      = $null
        }
        while ($smtpSuccess -ne $True) {
            while ($smtpServerConVal -ne $True) {
                ""
                $smtpSettings.smtpServer = Read-Host "Enter SMTP server"
                if ($smtpSettings.smtpServer -match "^(([a-zA-Z]{1})|([a-zA-Z]{1}[a-zA-Z]{1})|([a-zA-Z]{1}[0-9]{1})|([0-9]{1}[a-zA-Z]{1})|([a-zA-Z0-9][a-zA-Z0-9-_]{1,61}[a-zA-Z0-9]))\.([a-zA-Z]{2,6}|[a-zA-Z0-9-]{2,30}\.[a-zA-Z]{2,3})$") {
                    if (Test-Connection $smtpSettings.smtpServer -Count 1) {
                        Write-Host "SMTP server format and pinged sucessful" -ForegroundColor Green
                        ""
                        $smtpServerConVal = $True
                    }
                    else {
                        Write-Warning "The SMTP server could not be pinged please try again"
                        ""
                    }
                }
                else {
                    Write-Warning "The SMTP server does not match a proper domain format try again"
                    ""
                }
            }
            while ($smtpPortVal -ne $True) {
                $smtpSettings.smtpPort = Read-Host "Enter SMTP port"
                if ($smtpSettings.smtpPort -match "^([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$") {
                    $smtpPortVal = $True
                }
                else {
                    Write-Warning "The SMTP server port is invalid please try again"
                    ""
                }
            }
            while ($smtpUserVal -ne $True) {
                $smtpSettings.smtpUser = Read-Host "Enter the SMTP username"
                if ($smtpSettings.smtpUser -match "(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|`"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*`")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])") {
                    $smtpUserVal = $True
                }
                else {
                    Write-Warning "The SMTP username is not a valid email address please try again"
                    ""
                }
            }
            while ($null -eq $smtpSettings.smtpPassword -or $smtpSettings.smtpPassword.Count -lt 4) {
                $smtpSettings.smtpPassword = Read-Host "Enter the SMTP password"
                ""
            }
            while ($smtpSSL -ne "n" -and $smtpSSL -ne "y") {
                $smtpSSL = Read-Host "Enable SSL SMTP connections? (needed for Gmail) [y/n]"
                ""
            }
            if ($smtpSSL -eq "y") {
                $smtpSettings.smtpSSL = $True
            }
            else {
                $smtpSettings.smtpSSL = $False
            }
            $encrypted = ConvertTo-SecureString $smtpSettings.smtpPassword -AsPlainText -Force
            $credential = New-Object System.Management.Automation.PsCredential($smtpSettings.smtpUser, $encrypted)
            $SMTPClient = New-Object Net.Mail.SmtpClient($smtpSettings.smtpServer, $smtpSettings.smtpPort)
            $SMTPClient.EnableSsl = $smtpSettings.smtpSSL
            $SMTPClient.Credentials = $credential
            $Body = @"
This is a WinBackup7z SMTP test
"@
            $Subject = "This is a WinBackup7z SMTP test"
            try {
                $SMTPClient.Send($smtpSettings.smtpUser, $smtpSettings.smtpUser, $Subject, $Body)
                $smtpSuccess = $True
            }
            catch {
                $smtpSuccess = $False
            }
            if ($smtpSuccess -eq $True) {
                ""
                Write-Host "The SMTP message was sent successfully" -ForegroundColor Green
            }
            else {
                ""
                Write-Warning "The SMTP message failed to send successfully"
            }
        }
        $pathToSMTPJson = "C:\ProgramData\WinBackup7z\WinBackup7z.json"
        $smtpSettings | ConvertTo-Json | Set-Content $pathToSMTPJson
    }
}
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
$pathToBackupJson = "C:\ProgramData\WinBackup7z\WinBackup7z_$($backupSettings.backupName).json"
$backupSettings | ConvertTo-Json | Set-Content $pathToBackupJson
$taskFile = @'
$allBackups = Get-ChildItem "C:\ProgramData\WinBackup7z" | Where-Object Name -Like "WinBackup7z_*.json"
foreach ($backup in $allBackups) {
    $timeStart = Get-Date -UFormat '+%Y-%m-%dT%H-%M-%S'
    $pathToBackupJson = $backup.VersionInfo.FileName
    $backupSettings = Get-Content -Path $pathToBackupJson -Raw | ConvertFrom-Json
    $backupCount = Get-ChildItem "$($backupSettings.backupDestinationPath)\$($backupSettings.backupName)" | Where-Object Name -Like "WinBackup7z_$($backupSettings.backupName)_*.7z"
    if ([int]$backupSettings.backupDaysBeforeFull -eq [int]$backupSettings.backupCurrentCount -or $backupSettings.backupCurrentCount -eq 0) {
        $backupSettings.backupTimeStamp = Get-Date -UFormat '+%Y-%m-%dT%H-%M-%S'
        ."C:\Program Files\7-Zip\7z.exe" a -t7z "$($backupSettings.backupDestinationPath)\$($backupSettings.backupName)\WinBackup7z_$($backupSettings.backupName)_$($backupSettings.backupTimeStamp).7z" $backupSettings.backupSourcePath -mx9
        $backupSettings.backupCurrentCount = 0
        if ($backupCount.Count -eq $backupSettings.backupFullBackupsToKeep) {
            $purgeBackup = Get-ChildItem "$($backupSettings.backupDestinationPath)\$($backupSettings.backupName)" | Where-Object Name -Like "WinBackup7z_$($backupSettings.backupName)_*.7z" | Sort-Object LastWriteTime -Descending | Select-Object -Last 1
            Remove-Item $purgeBackup.VersionInfo.FileName
        }
    }
    else {
        ."C:\Program Files\7-Zip\7z.exe" u -up0q3r2x2y2z1w2 "$($backupSettings.backupDestinationPath)\$($backupSettings.backupName)\WinBackup7z_$($backupSettings.backupName)_$($backupSettings.backupTimeStamp).7z" $backupSettings.backupSourcePath -mx9
    }
    if ($backupSettings.backupFirst -eq $False) {
        $backupSettings.backupCurrentCount++
    }
    $backupSettings.backupFirst = $False
    if (Test-Path -Path "C:\ProgramData\WinBackup7z\WinBackup7z.json") {
        $timeEnd = Get-Date -UFormat '+%Y-%m-%dT%H-%M-%S'
        $backupFileSize = Get-Item "$($backupSettings.backupDestinationPath)\$($backupSettings.backupName)\WinBackup7z_$($backupSettings.backupName)_$($backupSettings.backupTimeStamp).7z".length/1MB
        $backupFolderSize = (Get-ChildItem "$($backupSettings.backupDestinationPath)\$($backupSettings.backupName)" -Recurse | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB
        $smtpSettings = Get-Content -Path $pathToSMTPJson -Raw | ConvertFrom-Json
        $encrypted = ConvertTo-SecureString $smtpSettings.smtpPassword -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PsCredential($smtpSettings.smtpUser, $encrypted)
        $SMTPClient = New-Object Net.Mail.SmtpClient($smtpSettings.smtpServer, $smtpSettings.smtpPort)
        $SMTPClient.EnableSsl = $smtpSettings.smtpSSL
        $SMTPClient.Credentials = $credential
        $Body = @"
Computer Name: $($env:COMPUTERNAME)
Domain: $($env:USERDOMAIN)
Time Started: $($timeStart)
Time Ended: $($timeEnd)
Backup Name: $($backupSettings.backupName)
Backup File Size: $($backupFileSize) MB
Backup Folder Size: $($backupFolderSize) MB
Full Backups to Keep: $($backupSettings.backupFullBackupsToKeep)
Days Before Full Backup: $($backupSettings.backupDaysBeforeFull)
Current Backup Count: $($backupSettings.backupCurrentCount)
"@
        $Subject = "WinBackup7z: Backup $($backupSettings.backupName) @ $($env:COMPUTERNAME) Completed"
        $SMTPClient.Send($smtpSettings.smtpUser, $smtpSettings.smtpUser, $Subject, $Body)
    }
    $backupSettings | ConvertTo-Json | Set-Content $pathToBackupJson
}
'@
Set-Content "C:\ProgramData\WinBackup7z\WinBackup7z.ps1" $taskFile
""
Write-Host "WinBackup7z Configured Successfully" -ForegroundColor Green -BackgroundColor Blue