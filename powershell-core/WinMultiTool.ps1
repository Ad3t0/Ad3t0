$timeScriptRun = Get-Date -UFormat '+%Y-%m-%dT%H-%M-%S'
$LogFileName = "C:\ProgramData\WinUpdate\$($timeScriptRun)-transcript.log"
Start-Transcript -Path $LogFileName
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
Clear-Host
""
Write-Host "1 - Install or update Chocolatey and basic dependencies and utilities"
Write-Host "2 - Remove all Windows temp files, run drive cleanup and remove old Windows versions"
Write-Host "3 - Install all Windows updates and reboot automatically untill all are complete"
Write-Host "4 - Auto reboot without warning (CAUTION)"
Write-Host "5 - Windows Debloat Edits"
Write-Host "7 - Windows Update Reset (Must be used alone)"
""
while ($functionsToRun -notlike "*1*" -and $functionsToRun -notlike "*2*" -and $functionsToRun -notlike "*3*" -and $functionsToRun -notlike "*4*" -and $functionsToRun -notlike "*5*" -and $functionsToRun -notlike "*6*" -and $functionsToRun -notlike "*7*") {
    $functionsToRun = Read-Host "Enter one or more functions to run [1/2/3/4/5/6/7]"
    $functionsToRun = $functionsToRun.ToString()
}
if ($functionsToRun -like "*2*" -and $functionsToRun -notlike "*7*") {
    $disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object FreeSpace
    $freeSpaceInitial = $disk.FreeSpace / 1GB
    $freeSpaceInitial = [math]::Round($freeSpaceInitial, 2)
    ""
    Write-Host "Current free space on C: = $($freeSpaceInitial)GB" -ForegroundColor Yellow
    ""
}
#################################################
if ($functionsToRun -like "*1*" -and $functionsToRun -notlike "*7*") {
    if (!(Test-Path -Path "C:\ProgramData\chocolatey\choco.exe")) {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        choco feature enable -n allowGlobalConfirmation
        choco feature enable -n skipPackageUpgradesWhenNotInstalled
        choco feature disable -n checksumFiles
    }
    else {
        choco feature enable -n allowGlobalConfirmation
        choco feature enable -n skipPackageUpgradesWhenNotInstalled
        choco feature disable -n checksumFiles
        choco upgrade chocolatey
    }
    $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    if ($osInfo.ProductType -ne 1) {
        choco install revo-uninstaller googlechrome vcredist-all dotnetfx directx notepadplusplus 7zip autoruns
    }
    else {
        choco install revo-uninstaller googlechrome vcredist-all dotnetfx directx dotnet3.5 javaruntime 7zip adobereader notepadplusplus
    }
}
#################################################
if ($functionsToRun -like "*2*" -and $functionsToRun -notlike "*7*") {
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
if ($functionsToRun -like "*3*" -and $functionsToRun -notlike "*7*") {
    if (!(Test-Path -Path "C:\ProgramData\WinUpdate")) {
        New-Item -Path "C:\ProgramData\WinUpdate" -ItemType "directory"
    }
    $pathToJson = "C:\ProgramData\WinUpdate\WinUpdate.json"
    $settingsBody = @{
        rebootCount = 0
    }
    $settingsJson = (ConvertTo-Json -depth 5 $settingsBody)
    Set-Content $pathToJson $settingsJson
    $taskFile = @'
$timeScriptRun = Get-Date -UFormat '+%Y-%m-%dT%H-%M-%S'
$LogFileName = "C:\ProgramData\WinUpdate\$($timeScriptRun)-transcript.log"
Start-Transcript -Path $LogFileName
while ($numIntExplorer -eq 0) {
    $numIntExplorer = (Get-Process -ea SilentlyContinue "explorer").Count
    Start-Sleep 1
}
Start-Sleep 20
$pathToJson = "C:\ProgramData\WinUpdate\WinUpdate.json"
$jsonSettings = Get-Content -Path $pathToJson -Raw | ConvertFrom-Json
$jsonSettings.rebootCount = [int]$jsonSettings.rebootCount
$jsonSettings.rebootCount = $jsonSettings.rebootCount + 1
$jsonSettings | ConvertTo-Json | Set-Content $pathToJson
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name PSWindowsUpdate -Confirm:$False -Force
Import-Module PSWindowsUpdate
Write-Warning "Downloading updates please wait..."
Add-WUServiceManager -ServiceID "7971f918-a847-4430-9279-4a52d1efe18d" -AddServiceFlag 7 -Confirm:$false
Write-Warning "Installing updates please wait..."
$getUpdates = Install-WindowsUpdate -Install -MicrosoftUpdate -ForceDownload -ForceInstall -IgnoreReboot -AcceptAll -SendHistory -Criteria "isinstalled=0 and deploymentaction=*"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticecaption" -Value "Updates In Progress"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticetext" -Value "Updates are still running and the system may periodically reboot. Reboot Count $($jsonSettings.rebootCount) Please wait..."
if (!($getUpdates) -or $jsonSettings.rebootCount -ge 6) {
    schtasks.exe /delete /tn WinUpdate /f
    Remove-Item -Path "C:\ProgramData\WinUpdate\WinUpdate.ps1" -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticecaption" -Value ""
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticetext" -Value ""
    shutdown /r /t 0 /f
    exit
}
Stop-Transcript
Start-Sleep 15
shutdown /r /t 0 /f
'@
    Set-Content "C:\ProgramData\WinUpdate\WinUpdate.ps1" $taskFile
    $Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-ExecutionPolicy Bypass -File C:\ProgramData\WinUpdate\WinUpdate.ps1"
    $Trigger = New-ScheduledTaskTrigger -AtStartup
    $Settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit 0 -AllowStartIfOnBatteries
    $Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings
    Register-ScheduledTask -TaskName 'WinUpdate' -InputObject $Task -User SYSTEM
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticecaption" -Value "Updates In Progress"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticetext" -Value "Updates are still running and the system may periodically reboot. Please wait..."
    $pendingReboot = Test-PendingReboot
    if (!($pendingReboot)) {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
        Install-Module -Name PSWindowsUpdate -Confirm:$False -Force
        Import-Module PSWindowsUpdate
        Write-Warning "Downloading updates please wait..."
        Add-WUServiceManager -ServiceID "7971f918-a847-4430-9279-4a52d1efe18d" -AddServiceFlag 7 -Confirm:$false
        Write-Warning "Installing updates please wait..."
        $getUpdates = Install-WindowsUpdate -Install -MicrosoftUpdate -ForceDownload -ForceInstall -IgnoreReboot -AcceptAll -SendHistory -Criteria "isinstalled=0 and deploymentaction=*"
        if (!($getUpdates)) {
            schtasks.exe /delete /tn WinUpdate /f
            Remove-Item -Path "C:\ProgramData\WinUpdate\WinUpdate.ps1" -Force
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticecaption" -Value ""
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticetext" -Value ""
        }
    }
}
#################################################
if ($functionsToRun -like "*5*" -and $functionsToRun -notlike "*7*") {
    # Change Windows PowerScheme to maximum performance
    $currScheme = powercfg /LIST | Select-String "High performance"
    $currScheme = $currScheme -split (" ")
    powercfg -SetActive $currScheme[3]
    # Registry changes
    $services = @(
        "*diagnosticshub*"
        "DiagTrack"
        "dmwappushservice"
        "lfsvc"
        "MapsBroker"
        "NetTcpPortSharing"
        "RemoteAccess"
        "RemoteRegistry"
        "SharedAccess"
        "TrkWks"
        "WMPNetworkSvc"
        "XblAuthManager"
        "XblGameSave"
        "XboxNetApiSvc"
        "MixedRealityOpenXRSvc"
        "WerSvc"
        "SysMain"
        "SCPolicySvc"
        "ScDeviceEnum"
        "WdiSystemHost"
        "WdiServiceHost"
        "SCardSvr"
        "RetailDemo"
        "WpcMonSvc"
        "DPS"
        "diagsvc"
    )
    foreach ($service in $services) {
        Write-Host "Stopping $service"
        Stop-Service -Name $service -Force
        Write-Host "Disabling $service"
        Get-Service -Name $service | Set-Service -StartupType Disabled
    }
    $appsToRemove = @("Microsoft Edge", "Microsoft Store", "Mail")
    foreach ($app in $appsToRemove) {
	((New-Object -Com Shell.Application).Namespace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | Where-Object { $_.Name -eq $app }).Verbs() | Where-Object { $_.Name.Replace('&', '') -match 'Unpin from taskbar' } | ForEach-Object { $_.DoIt(); $exec = $true } > $null 2>&1
    }
    [Array] @(
        "\Microsoft\Windows\ApplicationData\CleanupTemporaryState"
        "\Microsoft\Windows\ApplicationData\DsSvcCleanup"
        "\Microsoft\Windows\AppxDeploymentClient\Pre-stagedappcleanup"
        "\Microsoft\Windows\Autochk\Proxy"
        "\Microsoft\Windows\BrokerInfrastructure\BgTaskRegistrationMaintenanceTask"
        "\Microsoft\Windows\capabilityaccessmanager\maintenancetasks"
        "\Microsoft\Windows\Chkdsk\ProactiveScan"
        "\Microsoft\Windows\Chkdsk\SyspartRepair"
        "\Microsoft\Windows\Clip\LicenseValidation"
        "\Microsoft\Windows\CloudExperienceHost\CreateObjectTask"
        "\Microsoft\Windows\CustomerExperienceImprovementProgram\Consolidator"
        "\Microsoft\Windows\CustomerExperienceImprovementProgram\UsbCeip"
        "\Microsoft\Windows\Defrag\ScheduledDefrag"
        "\Microsoft\Windows\DeviceInformation\Device"
        "\Microsoft\Windows\DeviceInformation\DeviceUser"
        "\Microsoft\Windows\DeviceSetup\MetadataRefresh"
        "\Microsoft\Windows\ExploitGuard\ExploitGuardMDMpolicyRefresh"
        "\Microsoft\Windows\Feedback\Siuf\DmClient"
        "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload"
        "\Microsoft\Windows\FileHistory\FileHistory*"
        "\Microsoft\Windows\Location\Notifications"
        "\Microsoft\Windows\Location\WindowsActionDialog"
        "\Microsoft\Windows\Maps\MapsToastTask"
        "\Microsoft\Windows\Maps\MapsUpdateTask"
        "\Microsoft\Windows\MemoryDiagnostic\ProcessMemoryDiagnosticEvents"
        "\Microsoft\Windows\MemoryDiagnostic\RunFullMemoryDiagnostic"
        "\Microsoft\Windows\MUI\LPRemove"
        "\Microsoft\Windows\Multimedia\SystemSoundsService"
        "\Microsoft\Windows\OfflineFiles\BackgroundSynchronization"
        "\Microsoft\Windows\OfflineFiles\LogonSynchronization"
        "\Microsoft\Windows\Printing\EduPrintProv"
        "\Microsoft\Windows\Printing\PrinterCleanupTask"
        "\Microsoft\Windows\PushToInstall\LoginCheck"
        "\Microsoft\Windows\PushToInstall\Registration"
        "\Microsoft\Windows\RetailDemo\CleanupOfflineContent"
        "\Microsoft\Windows\Servicing\StartComponentCleanup"
        "\Microsoft\Windows\Setup\SetupCleanupTask"
        "\Microsoft\Windows\SharedPC\AccountCleanup"
        "\Microsoft\Windows\UNP\RunUpdateNotificationMgr"
        "\Microsoft\Windows\WindowsErrorReporting\QueueReporting"
        "\Microsoft\XblGameSave\XblGameSaveTask"
    ) | ForEach-Object {
        Disable-ScheduledTask -TaskName $_ -ErrorAction SilentlyContinue | Out-Null
        Write-Host "Task `"$($_)`" was disabled"
    }
    Write-Host "Disabling Telemetry..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
    Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" | Out-Null
    Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\ProgramDataUpdater" | Out-Null
    Disable-ScheduledTask -TaskName "Microsoft\Windows\Autochk\Proxy" | Out-Null
    Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" | Out-Null
    Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" | Out-Null
    Disable-ScheduledTask -TaskName "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" | Out-Null
    Write-Host "Disabling Application suggestions..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1
    Write-Host "Disabling Activity History..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Type DWord -Value 0
    Write-Host "Disabling Location Tracking..."
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type String -Value "Deny"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type DWord -Value 0
    Write-Host "Disabling automatic Maps updates..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\Maps" -Name "AutoUpdateEnabled" -Type DWord -Value 0
    Write-Host "Disabling Feedback..."
    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Type DWord -Value 1
    Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient" -ErrorAction SilentlyContinue | Out-Null
    Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" -ErrorAction SilentlyContinue | Out-Null
    Write-Host "Disabling Tailored Experiences..."
    If (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
        New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -Type DWord -Value 1
    Write-Host "Disabling Advertising ID..."
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Type DWord -Value 1
    Write-Host "Disabling Error reporting..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Type DWord -Value 1
    Disable-ScheduledTask -TaskName "Microsoft\Windows\Windows Error Reporting\QueueReporting" | Out-Null
    Write-Host "Stopping and disabling Diagnostics Tracking Service..."
    Stop-Service "DiagTrack" -WarningAction SilentlyContinue
    Set-Service "DiagTrack" -StartupType Disabled
    Write-Host "Stopping and disabling WAP Push Service..."
    Stop-Service "dmwappushservice" -WarningAction SilentlyContinue
    Set-Service "dmwappushservice" -StartupType Disabled
    Write-Host "Enabling F8 boot menu options..."
    bcdedit /set `{current`} bootmenupolicy Legacy | Out-Null
    Write-Host "Disabling Remote Assistance..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 0
    Write-Host "Disabling Storage Sense..."
    Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Recurse -ErrorAction SilentlyContinue
    Write-Host "Stopping and disabling Superfetch service..."
    Stop-Service "SysMain" -WarningAction SilentlyContinue
    Set-Service "SysMain" -StartupType Disabled
    Write-Host "Showing task manager details..."
    $taskmgr = Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -PassThru
    Do {
        Start-Sleep -Milliseconds 100
        $preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
    } Until ($preferences)
    Stop-Process $taskmgr
    $preferences.Preferences[28] = 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -Type Binary -Value $preferences.Preferences
    Write-Host "Showing file operations details..."
    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" -Name "EnthusiastMode" -Type DWord -Value 1
    Write-Host "Hiding Task View button..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0
    Write-Host "Hiding People icon..."
    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWord -Value 0
    Write-Host "Enabling NumLock after startup..."
    If (!(Test-Path "HKU:")) {
        New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS | Out-Null
    }
    Set-ItemProperty -Path "HKU:\.DEFAULT\Control Panel\Keyboard" -Name "InitialKeyboardIndicators" -Type DWord -Value 2147483650
    Write-Host "Changing default Explorer view to This PC..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWord -Value 1
    Write-Host "Hiding 3D Objects icon from This PC..."
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Recurse -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Type DWord -Value 4194304
    Write-Host "Disable News and Interests"
    if (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds")) {
        New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -Type DWord -Value 0
    #Remove news and interest from taskbar
    Set-ItemProperty -Path  "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarViewMode" -Type DWord -Value 2
    #Remove meet now button from taskbar
    If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "HideSCAMeetNow" -Type DWord -Value 1
    Write-Host "Removing AutoLogger file and restricting directory..."
    $autoLoggerDir = "$env:PROGRAMDATA\Microsoft\Diagnosis\ETLLogs\AutoLogger"
    If (Test-Path "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl") {
        Remove-Item "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl"
    }
    icacls $autoLoggerDir /deny SYSTEM:`(OI`)`(CI`)F | Out-Null
    #Disable LockScreen
    If (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization")) {
        New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization" | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreen" -Type DWord -Value 1
    write-Host "Lock Screen has been disabled"
    #Disable Advertising ID
    If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0
    write-Host "Advertising ID has been disabled"
    #Disable SmartScreen
    if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer")) {
        New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmartScreenEnabled" -Type String -Value "Off"
    if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost")) {
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -Value 0
    write-Host "SmartScreen has been disabled"
    #Disable File History
    if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\FileHistory")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\FileHistory" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\FileHistory" -Name "Disabled" -Type DWord -Value 1
    #Disable Hand Writing Reports
    if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" -Name "PreventHandwritingErrorReports" -Type DWord -Value 1
    #Disable Location Tracking...
    if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocation" -Type DWord -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocationScripting" -Type DWord -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableSensors" -Type DWord -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableWindowsLocationProvider" -Type DWord -Value 1
    #Disable Auto Map Downloading/Updating
    if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Maps")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Maps" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Maps" -Name "AutoDownloadAndUpdateMapData" -Type DWord -Value 0
    if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings" -Force | Out-Null
    }
    Get-ChildItem -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings" -ErrorAction SilentlyContinue | ForEach-Object {
        Set-ItemProperty -Path $_.PsPath -Name "Enabled" -Type DWord -Value 0
        Set-ItemProperty -Path $_.PsPath -Name "LastNotificationAddedTime" -Type QWord -Value "0"
    }
    #Disable Windows Feeds
    if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -Type DWord -Value 0
    #Disable Game DVR
    if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0
    #Disable Keyboard BS
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Value "506"
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "Flags" -Value "122"
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\ToggleKeys" -Name "Flags" -Value "58"
    #Disable Mitigations
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name FeatureSettingsOverride -Value 3
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name FeatureSettingsOverrideMask -Value 3
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\DoSvc" -Name Start -Value 4
    if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching")) { New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" -Force -ErrorAction SilentlyContinue }
    if (!(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power")) { New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Force -ErrorAction SilentlyContinue }
    if (!(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling")) { New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" -Force -ErrorAction SilentlyContinue }
    if (!(Test-Path "HKCU:\System\GameConfigStore")) { New-Item -Path "HKCU:\System\GameConfigStore" -Force -ErrorAction SilentlyContinue }
    if (!(Test-Path "HKCU:\Control Panel\Desktop")) { New-Item -Path "HKCU:\Control Panel\Desktop" -Force -ErrorAction SilentlyContinue }
    if (!(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\943c8cb6-6f93-4227-ad87-e9a3feec08d1")) { New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\943c8cb6-6f93-4227-ad87-e9a3feec08d1" -Force -ErrorAction SilentlyContinue }
    if (!(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\d4e98f31-5ffe-4ce1-be31-1b38b384c009\DefaultPowerSchemeValues\8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c")) { New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\d4e98f31-5ffe-4ce1-be31-1b38b384c009\DefaultPowerSchemeValues\8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" -Force -ErrorAction SilentlyContinue }
    New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching' -Name 'SearchOrderConfig' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name 'HiberbootEnabled' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling' -Name 'PowerThrottlingOff' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKCU:\System\GameConfigStore' -Name 'GameDVR_Enabled' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKCU:\System\GameConfigStore' -Name 'GameDVR_FSEBehaviorMode' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKCU:\System\GameConfigStore' -Name 'Win32_AutoGameModeDefaultProfile' -Value ([byte[]](0x01, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)) -PropertyType Binary -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKCU:\System\GameConfigStore' -Name 'Win32_GameModeRelatedProcesses' -Value ([byte[]](0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)) -PropertyType Binary -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKCU:\System\GameConfigStore' -Name 'GameDVR_HonorUserFSEBehaviorMode' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKCU:\System\GameConfigStore' -Name 'GameDVR_DXGIHonorFSEWindowsCompatible' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKCU:\System\GameConfigStore' -Name 'GameDVR_EFSEFeatureFlags' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKCU:\Control Panel\Desktop' -Name 'MenuShowDelay' -Value '0' -PropertyType String -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKCU:\Control Panel\Desktop' -Name 'WaitToKillAppTimeout' -Value '5000' -PropertyType String -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKCU:\Control Panel\Desktop' -Name 'HungAppTimeout' -Value '4000' -PropertyType String -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKCU:\Control Panel\Desktop' -Name 'AutoEndTasks' -Value '1' -PropertyType String -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKCU:\Control Panel\Desktop' -Name 'LowLevelHooksTimeout' -Value 4096 -PropertyType DWord -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKCU:\Control Panel\Desktop' -Name 'WaitToKillServiceTimeout' -Value 8192 -PropertyType DWord -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\943c8cb6-6f93-4227-ad87-e9a3feec08d1' -Name 'Attributes' -Value 2 -PropertyType DWord -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\d4e98f31-5ffe-4ce1-be31-1b38b384c009\DefaultPowerSchemeValues\381b4222-f694-41f0-9685-ff5bb260df2e' -Name 'ACSettingIndex' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\d4e98f31-5ffe-4ce1-be31-1b38b384c009\DefaultPowerSchemeValues\381b4222-f694-41f0-9685-ff5bb260df2e' -Name 'DCSettingIndex' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\d4e98f31-5ffe-4ce1-be31-1b38b384c009\DefaultPowerSchemeValues\8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c' -Name 'ACSettingIndex' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb\DefaultPowerSchemeValues\381b4222-f694-41f0-9685-ff5bb260df2e' -Name 'ACSettingIndex' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb\DefaultPowerSchemeValues\381b4222-f694-41f0-9685-ff5bb260df2e' -Name 'DCSettingIndex' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb\DefaultPowerSchemeValues\8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c' -Name 'ACSettingIndex' -Value 0 -PropertyType DWord -Force -ea SilentlyContinue;
    Write-Host "Disabling Bing Search in Start Menu..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Type DWord -Value 1
    Write-Host "Hiding Taskbar Search icon / box..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0
    Write-Host "Search tweaks completed"
    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0
    Write-Host "Disabling background application access..."
    Get-ChildItem -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" |  ForEach-Object {
        if ($_.PsPath -notlike "*Search*") {
            Set-ItemProperty -Path $_.PsPath -Name "Disabled" -Type DWord -Value 1
            Set-ItemProperty -Path $_.PsPath -Name "DisabledByUser" -Type DWord -Value 1
        }
        else {
            Write-Host "Not disabling background access for $($_.PsPath)"
            Set-ItemProperty -Path $_.PsPath -Name "Disabled" -Type DWord -Value 0
            Set-ItemProperty -Path $_.PsPath -Name "DisabledByUser" -Type DWord -Value 0
        }
    }
    if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Type DWord -Value 1
    Write-Host "Enabling BackgroundAppGlobalToggle (breaks start menu search if disabled)"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BackgroundAppGlobalToggle" -Type DWord -Value 1
    Write-Host "Disabled bloatware background application access"
    New-Item -Path "HKCU:\SOFTWARE\Classes\CLSID" -Force | Out-Null
    New-Item -Path "HKCU:\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Force | Out-Null
    New-Item -Path "HKCU:\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Force -Value "" | Out-Null
    # Remove OneDrive
    Write-Host "Disabling OneDrive..."
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 1
    Write-Host "Uninstalling OneDrive..."
    Stop-Process -Name *onedrive* -ErrorAction SilentlyContinue -Force
    Start-Sleep -Seconds 2
    $onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
    If (!(Test-Path $onedrive)) {
        $onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
    }
    Start-Process $onedrive "/uninstall" -NoNewWindow -Wait
    Start-Sleep -Seconds 2
    Start-Sleep -Seconds 2
    Remove-Item -Path "$env:USERPROFILE\OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:PROGRAMDATA\Microsoft OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:SYSTEMDRIVE\OneDriveTemp" -Force -Recurse -ErrorAction SilentlyContinue
    If (!(Test-Path "HKCR:")) {
        New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
    }
    Remove-Item -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -ErrorAction SilentlyContinue
    If ((Get-ChildItem "$env:userprofile\OneDrive" -Recurse | Measure-Object).Count -eq 0) {
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:userprofile\OneDrive"
    }
    Write-Host "Disabled OneDrive"
    Write-Host "Enabling Dark Mode"
    if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes" -Name "AppsUseLightTheme" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes" -Name "SystemUsesLightTheme" -Type DWord -Value 0
    if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes" -Force | Out-Null
    }
    if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Type DWord -Value 0
    Write-Host "Enabled Dark Mode"
    Write-Host "Removing bloatware ... Wait ..."
    $BloatwareList = @(
        "*BingNews*"
        "*BingWeather*"
        "*GetHelp*"
        "*Getstarted*"
        "*MicrosoftOfficeHub*"
        "*MicrosoftSolitaireCollection*"
        "*PowerAutomateDesktop*"
        "*SecHealthUI*"
        "*People*"
        "*Todos*"
        "*WindowsAlarms*"
        "*windowscommunicationsapps*"
        "*WindowsFeedbackHub*"
        "*WindowsMaps*"
        "*WindowsSoundRecorder*"
        "*YourPhone*"
        "*Zune*"
        "*Parental*"
        "*MicrosoftTeams*"
        "*OneNote*"
        "*Spotify*"
        "*Disney*"
        "*Xbox*"
        "*Gaming*"
        "*Zoom*"
        "*Skype*"
        "*3DViewer*"
        "*MixedReality*"
        "*Wallet*"
    )
    foreach ($Bloat in $BloatwareList) {
        if ((Get-AppxPackage -Name $Bloat).NonRemovable -eq $false) {
            Write-Host "Trying to remove `"" -NoNewline
            Write-Host $Bloat -NoNewline
            Write-Host "`" Package! Be patient..."
            Get-AppxPackage -Name $Bloat | Remove-AppxPackage -ErrorAction SilentlyContinue | Out-Null
            Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
        }
    }
    Write-Host "Bloatware is removed."
}
if ($functionsToRun -like "*7*") {
    $arch = Get-WMIObject -Class Win32_Processor -ComputerName LocalHost | Select-Object AddressWidth
    Write-Host "Stopping Windows Update Services..." -ForegroundColor Yellow
    Stop-Service -Name BITS
    Write-Host "BITS Service Stopped" -ForegroundColor Yellow
    Stop-Service -Name wuauserv
    Write-Host "wuauserv Service Stopped" -ForegroundColor Yellow
    Stop-Service -Name appidsvc
    Write-Host "appidsvc Service Stopped" -ForegroundColor Yellow
    Stop-Service -Name cryptsvc
    Write-Host "cryptsvc Service Stopped" -ForegroundColor Yellow
    Write-Host "Removing QMGR Data file..." -ForegroundColor Yellow
    Remove-Item "$env:allusersprofile\Application Data\Microsoft\Network\Downloader\qmgr*.dat" -ErrorAction SilentlyContinue
    Write-Host "Renaming the Software Distribution and CatRoot Folder..." -ForegroundColor Yellow
    Rename-Item $env:systemroot\SoftwareDistribution SoftwareDistribution.bak -ErrorAction SilentlyContinue
    Rename-Item $env:systemroot\System32\Catroot2 catroot2.bak -ErrorAction SilentlyContinue
    Write-Host "Removing old Windows Update log..." -ForegroundColor Yellow
    Remove-Item $env:systemroot\WindowsUpdate.log -ErrorAction SilentlyContinue
    Write-Host "Resetting the Windows Update Services to defualt settings..." -ForegroundColor Yellow
    sc.exe sdset bits "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
    sc.exe sdset wuauserv "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
    Set-Location $env:systemroot\system32
    Write-Host "Registering some DLLs..." -ForegroundColor Yellow
    regsvr32.exe /s atl.dll
    regsvr32.exe /s urlmon.dll
    regsvr32.exe /s mshtml.dll
    regsvr32.exe /s shdocvw.dll
    regsvr32.exe /s browseui.dll
    regsvr32.exe /s jscript.dll
    regsvr32.exe /s vbscript.dll
    regsvr32.exe /s scrrun.dll
    regsvr32.exe /s msxml.dll
    regsvr32.exe /s msxml3.dll
    regsvr32.exe /s msxml6.dll
    regsvr32.exe /s actxprxy.dll
    regsvr32.exe /s softpub.dll
    regsvr32.exe /s wintrust.dll
    regsvr32.exe /s dssenh.dll
    regsvr32.exe /s rsaenh.dll
    regsvr32.exe /s gpkcsp.dll
    regsvr32.exe /s sccbase.dll
    regsvr32.exe /s slbcsp.dll
    regsvr32.exe /s cryptdlg.dll
    regsvr32.exe /s oleaut32.dll
    regsvr32.exe /s ole32.dll
    regsvr32.exe /s shell32.dll
    regsvr32.exe /s initpki.dll
    regsvr32.exe /s wuapi.dll
    regsvr32.exe /s wuaueng.dll
    regsvr32.exe /s wuaueng1.dll
    regsvr32.exe /s wucltui.dll
    regsvr32.exe /s wups.dll
    regsvr32.exe /s wups2.dll
    regsvr32.exe /s wuweb.dll
    regsvr32.exe /s qmgr.dll
    regsvr32.exe /s qmgrprxy.dll
    regsvr32.exe /s wucltux.dll
    regsvr32.exe /s muweb.dll
    regsvr32.exe /s wuwebv.dll
    Write-Host "Removing WSUS client settings..." -ForegroundColor Yellow
    Remove-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate -Name AccountDomainSid -ErrorAction SilentlyContinue
    Remove-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate -Name PingID -ErrorAction SilentlyContinue
    Remove-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate -Name SusClientId -ErrorAction SilentlyContinue
    Remove-ItemProperty HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU -Name UseWUServer -ErrorAction SilentlyContinue
    Remove-ItemProperty HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate -Name WUServer -ErrorAction SilentlyContinue
    Remove-ItemProperty HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate -Name DisableWindowsUpdateAccess -ErrorAction SilentlyContinue
    Remove-ItemProperty "HKLM:\SYSTEM\Internet Communication Management\Internet Communication" -Name DisableWindowsUpdateAccess -ErrorAction SilentlyContinue
    Remove-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate -Name DisableWindowsUpdateAccess -ErrorAction SilentlyContinue
    New-Item -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate -ErrorAction SilentlyContinue
    New-Item -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU -ErrorAction SilentlyContinue
    New-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU -Name NoAutoRebootWithLoggedOnUsers -Value 1 -ErrorAction SilentlyContinue
    New-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU -Name NoAutoUpdate -Value 1 -ErrorAction SilentlyContinue
    Write-Host "Resetting the WinSock..." -ForegroundColor Yellow
    netsh winsock reset
    netsh winhttp reset proxy
    Write-Host "Delete all BITS jobs..." -ForegroundColor Yellow
    Get-BitsTransfer | Remove-BitsTransfer
    Write-Host "Attempting to install the Windows Update Agent..." -ForegroundColor Yellow
    if ($arch -eq 64) {
        wusa Windows8-RT-KB2937636-x64 /quiet
    }
    else {
        wusa Windows8-RT-KB2937636-x86 /quiet
    }
    Write-Host "Starting Windows Update Services..." -ForegroundColor Yellow
    sc.exe config wuauserv start= delayed-auto
    sc.exe config BITS start= delayed-auto
    Start-Service -Name BITS
    Start-Service -Name wuauserv
    Start-Service -Name appidsvc
    Start-Service -Name cryptsvc
    Write-Host "Forcing discovery..." -ForegroundColor Yellow
    wuauclt /resetauthorization /detectnow
}
#################################################
if ($functionsToRun -like "*2*" -and $functionsToRun -notlike "*7*") {
    $disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object FreeSpace
    $freeSpace = $disk.FreeSpace / 1GB
    $freeSpace = [math]::Round($freeSpace, 2)
    ""
    Write-Host "Free space before on C: = $($freeSpaceInitial)GB" -ForegroundColor Yellow
    Write-Host "Free space after on C: = $($freeSpace)GB" -ForegroundColor Green
    ""
}
Stop-Transcript
$pendingReboot = $null
if ($functionsToRun -like "*4*") {
    if (!($getUpdates)) {
        Write-Host "Script is complete. Rebooting in 5 seconds..." -ForegroundColor Green
        Start-Sleep 5
        Restart-Computer -Force
        exit
    }
}
else {
    Write-Host "Process complete. Please reboot your computer." -ForegroundColor Green
    while ($rebootConfirm -ne "n" -and $rebootConfirm -ne "y") {
        $rebootConfirm = Read-Host "Reboot now? [y/n]"
    }
    if ($rebootConfirm -eq "y") {
        Restart-Computer -Force
        exit
    }
}