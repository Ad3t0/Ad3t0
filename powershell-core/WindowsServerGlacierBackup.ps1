$ver = "1.0.7"
Write-Host $ver -ForegroundColor Green
if (!(Test-Path -Path "$($env:ProgramData)\powershell-bin\"))
{ New-Item -Path $env:ProgramData -Name "powershell-bin" -ItemType "directory"
} $backupDate = Get-Date -Format "MMddyy"
$ErrorActionPreference = "SilentlyContinue"
Stop-Transcript | Out-Null
$ErrorActionPreference = "Continue"
Start-Transcript -Path "$($env:ProgramData)\powershell-bin\$($env:USERDOMAIN)_WSGBLOG_$($backupDate).txt" -Append
# SMTP Email
$SMTPEmailFile = "$($env:ProgramData)\powershell-bin\SMTPEmail"
if (!(Test-Path -Path "$($env:ProgramData)\powershell-bin\SMTPEmail"))
{ $SMTPEmail = Read-Host "Enter the SMTP email address"
	$SMTPEmail | Out-File $SMTPEmailFile
} $SMTPEmail = Get-Content $SMTPEmailFile
# SMTP Password
$empassFile = "$($env:ProgramData)\powershell-bin\EMPASSHash"
if (!(Test-Path -Path $empassFile))
{ $empass = Read-Host "Enter the SMTP email password"
	$empass | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File $empassFile
} $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $SMTPEmail,(Get-Content $empassFile | ConvertTo-SecureString)
# Alert Email
$AlertEmailFile = "$($env:ProgramData)\powershell-bin\AlertEmailFile"
if (!(Test-Path -Path $AlertEmailFile))
{ $AlertEmail = Read-Host "Enter the alert email address"
	$AlertEmail | Out-File $AlertEmailFile
} $AlertEmail = Get-Content $AlertEmailFile
# Backup path file
$BackupPathFile = "$($env:ProgramData)\powershell-bin\BackupPathFile"
if (!(Test-Path -Path $BackupPathFile))
{ $BackupPath = Read-Host "Enter the full UNC network backup path"
	$BackupPath | Out-File $BackupPathFile
} $BackupPath = Get-Content $BackupPathFile
if (Test-Path -Path "$($BackupPath)\WindowsImageBackup*")
{ Remove-Item -Path "$($BackupPath)\WindowsImageBackup*" -Recurse -Force
} $DriveLettersFile = "$($env:ProgramData)\powershell-bin\DriveLettersFile"
if (!(Test-Path -Path $DriveLettersFile))
{ $DriveLetters = Read-Host "Enter the drive letters to backup separated by commas without collons"
	$DriveLetters | Out-File $DriveLettersFile
} $DriveLetters = Get-Content $DriveLettersFile
$DriveLetters = $DriveLetters.Split(",")
$Policy = New-WBPolicy
foreach ($Drive in $DriveLetters)
{ $Volume = Get-WBVolume -VolumePath "$($Drive):"
	Add-WBVolume -Policy $Policy -Volume $Volume
} Add-WBSystemState $Policy
Add-WBBareMetalRecovery $Policy
$NetworkBackupLocation = New-WBBackupTarget -NetworkPath $BackupPath
Add-WBBackupTarget -Policy $Policy -Target $NetworkBackupLocation
Set-WBVssBackupOptions -Policy $Policy -VssCopyBackup
$startTimeBackup = Get-Date
$mailBodyStart = @"
Backup Start Time: $($startTimeBackup)
"@
Send-MailMessage -From $SMTPEmail -To $AlertEmail -Subject "Backup Started: $($env:USERDOMAIN)" -Body $mailBodyStart -SmtpServer "smtp.gmail.com" -Port "587" -UseSsl -Credential $cred -DeliveryNotificationOption OnSuccess
Start-WBBackup -Policy $Policy
Sleep 5
$backupName = "$($BackupPath)\WindowsImageBackup$($backupDate)"
Rename-Item -Path "$($BackupPath)\WindowsImageBackup" -NewName $backupName
$endTimeBackupServer = Get-Date
$backupSize = "{0:N2} MB" -f ((Get-ChildItem "$($BackupPath)\WindowsImageBackup$($backupDate)" -Recurse | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB)
$mailBodyEndServer = @"
Windows Backup End Time: $($endTimeBackupServer)
Backup Size: $($backupSize)
"@
Send-MailMessage -From $SMTPEmail -To $AlertEmail -Subject "Windows Backup Ended: $($env:USERDOMAIN)" -Body $mailBodyEndServer -SmtpServer "smtp.gmail.com" -Port "587" -UseSsl -Credential $cred -DeliveryNotificationOption OnSuccess
Sleep 5
. "C:\Program Files\FastGlacier\glacier-con.exe" sync $env:USERDOMAIN $backupName us-west-2 $env:USERDOMAIN/ ncds
$endTimeBackupGlacier = Get-Date
$mailBodyEndGlacier = @"
Glacier Backup End Time: $($endTimeBackupGlacier)
"@
Stop-Transcript
Sleep 5
Send-MailMessage -From $SMTPEmail -To $AlertEmail -Subject "Glacier Backup Ended: $($env:USERDOMAIN)" -Body $mailBodyEndGlacier -Attachments "$($env:ProgramData)\powershell-bin\$($env:USERDOMAIN)_WSGBLOG_$($backupDate)" -SmtpServer "smtp.gmail.com" -Port "587" -UseSsl -Credential $cred -DeliveryNotificationOption OnSuccess
