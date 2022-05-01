Clear-Host
""
Write-Host "Define Task Name"
$taskName = Read-Host "Choose a name for the scheduled task"
""
Write-Host "Define Task Trigger"
Write-Host "1 - Startup"
Write-Host "2 - Login"
""
while ($taskTrigger -ne "1" -and $taskTrigger -ne "2") {
    $taskTrigger = Read-Host "Choose between a startup or login task trigger [1/2/]"
}
""
Write-Host "Define Run As User. For domain, format like DOMAIN\Username"
while (!($verifiedCreds)) {
    $taskUser = Read-Host "Enter the task user"
    if ($taskUser -eq "SYSTEM") {
        $goodCreds = $true
    }
    else {
        $taskKey = Read-Host "Enter the task password"
        $computer = $env:COMPUTERNAME
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
        $obj = New-Object System.DirectoryServices.AccountManagement.PrincipalContext ('machine', $computer)
        $goodCreds = $obj.ValidateCredentials($taskUser, $taskKey)
    }
    if ($goodCreds) {
        $verifiedCreds = $true
        ""
        Write-Host "Credentials validated successfully" -ForegroundColor Green
        ""
    }
    else {
        ""
        Write-Warning "Credentials failed to validate"
        ""
    }
}
$taskFile = ""
while (!($taskFile -like "*.ps1")) {
    Read-Host "Press ENTER to open file selection window and select task"
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $objForm = New-Object System.Windows.Forms.$("OpenFileDialog")
    $objForm.ShowDialog() | Out-Null
    $taskFile = $objForm.$("FileName")
    if (!($taskFile -like "*.ps1")) {
        Write-Warning "Please select a .ps1 file"
        ""
    }
}
""
if ($taskTrigger -eq "1") {
    $Trigger = New-ScheduledTaskTrigger -AtStartup
}
if ($taskTrigger -eq "2") {
    $Trigger = New-ScheduledTaskTrigger -AtLogon -User $taskUser
}
$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument " -ExecutionPolicy Bypass -File $($taskFile)"
$Settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit 0 -AllowStartIfOnBatteries
if ($taskUser -eq "SYSTEM") {
    $Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings
    Register-ScheduledTask -TaskName $taskName -InputObject $Task -User SYSTEM -Force
}
else {
    $Principal = New-ScheduledTaskPrincipal -UserId $taskUser -LogonType Interactive -RunLevel Limited
    $Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal
    Register-ScheduledTask -TaskName $taskName -InputObject $Task -User $taskUser -Password $taskKey -Force
}
