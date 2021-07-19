[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$functionsToRun = $null
function Test-PendingReboot {
    if (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -EA Ignore) { return $true }
    if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) { return $true }
    if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -EA Ignore) { return $true }
    try {
        $util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
        $status = $util.DetermineIfRebootPending()
        if (($null -ne $status) -and $status.RebootPending) {
            return $true
        }
    }
    catch { }
    return $false
}
$pendingReboot = Test-PendingReboot
if ($pendingReboot) {
    while ($confirmationreboot -ne "n" -and $confirmationreboot -ne "y") {
        $confirmationreboot = Read-Host "Reboot is pending, reboot this PC now? [y/n]"
    } if ($confirmationreboot -eq "y") {
        Restart-Computer -Force
        exit
    }
}
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
$disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object FreeSpace
$freeSpaceInitial = $disk.FreeSpace / 1GB
$freeSpaceInitial = [math]::Round($freeSpaceInitial, 2)
""
Write-Host "Current free space on C: = $($freeSpaceInitial)GB" -ForegroundColor Yellow
""
#################################################
if ($functionsToRun -like "*1*") {
    if (!(Test-Path -Path "C:\ProgramData\chocolatey\choco.exe")) {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        choco feature enable -n=allowGlobalConfirmation
        choco feature disable -n=checksumFiles
    }
    $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    if ($osInfo.ProductType -ne 1) {
        choco install powershell googlechrome vcredist-all dotnetfx directx notepadplusplus 7zip revo-uninstaller autoruns
    }
    else {
        choco install powershell googlechrome vcredist-all dotnetfx directx dotnet3.5 javaruntime 7zip adobereader revo-uninstaller
    }
}
#################################################
if ($functionsToRun -like "*2*") {
    $folders = @('C:\Windows\Temp\*', 'C:\Documents and Settings\*\Local Settings\temp\*', 'C:\Users\*\Appdata\Local\Temp\*', 'C:\Users\*\Appdata\Local\Microsoft\Windows\Temporary Internet Files\*', 'C:\Windows\SoftwareDistribution\Download', 'C:\Windows\System32\FNTCACHE.DAT')
    $folders
    foreach ($folder in $folders) {
        ""
        Write-Host "Removing files in $($folder)" -ForegroundColor Yellow
        ""
        Remove-Item $folder -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "Finished removing files in $($folder)" -ForegroundColor Yellow
    }
    Write-Host "Running cleanmgr autoclean all drives." -ForegroundColor Yellow
    Start-Process -FilePath "C:\Windows\System32\cleanmgr.exe" -ArgumentList " /AUTOCLEAN" -Wait -PassThru
    ""
    Write-Host "Finished removing all temp files." -ForegroundColor Green
}
#################################################
if ($functionsToRun -like "*3*") {
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
$getUpdates = Get-WUInstall -AcceptAll -AutoReboot -SendHistory
$getUpdates | Format-List | Out-String | Add-Content "C:\ProgramData\WinUpdate\$($timeScriptRun).log"
$installUpdates = Install-WindowsUpdate -AcceptAll -AutoReboot -SendHistory
$installUpdates | Format-List | Out-String |  Add-Content "C:\ProgramData\WinUpdate\$($timeScriptRun).log"
if (!($getUpdates) -or $jsonSettings.rebootCount -ge 6) {
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
    try {
        Import-Module PSWindowsUpdate
    }
    catch {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
        Install-Module -Name PSWindowsUpdate -Confirm:$False -Force
        Import-Module PSWindowsUpdate
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticecaption" -Value "Updates In Progress"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticetext" -Value "Updates are still running and the system may periodically reboot. Please wait..."
    Clear-Host
    Write-Host "`r`n`r`n`r`n`r`n`r`n`r`n`r`n"
    Write-Warning "Downloading updates please wait..."
    $getUpdates = Get-WUInstall -AcceptAll -AutoReboot -SendHistory
    $getUpdates | Format-List | Out-String | Set-Content "C:\ProgramData\WinUpdate\$($timeScriptRun).log"
    Clear-Host
    Write-Host "`r`n`r`n`r`n`r`n`r`n`r`n`r`n"
    $getUpdates | Format-Table
    Add-Content "C:\ProgramData\WinUpdate\$($timeScriptRun).log" "------------------------------------"
    Write-Warning "Installing updates please wait..."
    $installUpdates = Install-WindowsUpdate -AcceptAll -AutoReboot -SendHistory
    $installUpdates | Format-List | Out-String | Add-Content "C:\ProgramData\WinUpdate\$($timeScriptRun).log"
    if (!($getUpdates)) {
        schtasks.exe /delete /tn WinUpdate /f
        Remove-Item -Path "C:\ProgramData\WinUpdate\WinUpdate.ps1" -Force
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticecaption" -Value ""
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticetext" -Value ""
    }
}
#################################################
$disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object FreeSpace
$freeSpace = $disk.FreeSpace / 1GB
$freeSpace = [math]::Round($freeSpace, 2)
""
Write-Host "Free space before on C: = $($freeSpaceInitial)GB" -ForegroundColor Yellow
Write-Host "Free space after on C: = $($freeSpace)GB" -ForegroundColor Green
""
if ($functionsToRun -like "*4*") {
    Write-Warning "Rebooting in 5 seconds..."
    Start-Sleep 5
    Restart-Computer -Force
    exit
}
$confirmationreboot = $null
$pendingReboot = $null
$pendingReboot = Test-PendingReboot
if ($pendingReboot) {
    while ($confirmationreboot -ne "n" -and $confirmationreboot -ne "y") {
        $confirmationreboot = Read-Host "Reboot is required, reboot this PC now? [y/n]"
    } if ($confirmationreboot -eq "y") {
        Restart-Computer -Force
        exit
    }
}