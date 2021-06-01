while ($fileTempConf -ne "n" -and $fileTempConf -ne "y") {
    ""
    $fileTempConf = Read-Host "Install all Windows updates rebooting automatically untill all are complete? [y/n]"
}






$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "C:\ProgramData\PSS3B-Data\PSS3B-Task.ps1"
$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $COMBOBOX_Day.text -At $TEXTBOX_Time.text
$Settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit 0
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings
Register-ScheduledTask -TaskName 'PSS3B_Run' -InputObject $Task -User $TEXTBOX_Username.text -Password $TEXTBOX_Password.text






Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name PSWindowsUpdate -Confirm:$False -Force
Import-Module PSWindowsUpdate
Get-WUInstall -AcceptAll -AutoReboot
Install-WindowsUpdate -AcceptAll -AutoReboot