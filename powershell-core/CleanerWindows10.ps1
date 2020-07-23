if (!([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544"))) {
	Write-Warning "Powershell is not running as Administrator. Exiting..."
	Start-Sleep 3
	Return
}
$PSVer = $PSVersionTable
if ($PSVer.PSVersion.Major -lt 5) {
	Write-Warning "Powershell version is $($PSVer.PSVersion.Major). Version 5.1 is needed please update using the following web page. Exiting..."
	Start-Sleep 3
	$URL = "https://www.microsoft.com/en-us/download/details.aspx?id=54616"
	Start-Process $URL
	Return
}
$ErrorActionPreference = "SilentlyContinue"
$systemmodel = wmic computersystem get model /VALUE
$systemmodel = $systemmodel -replace ('Model=', '')
$currentversion = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ReleaseId" -ErrorAction SilentlyContinue
$productname = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ProductName" -ErrorAction SilentlyContinue
Write-Host $ver -ForegroundColor Green
Write-Host $text
Write-Host " System Model: " -ForegroundColor yellow -NoNewline
Write-Host $systemmodel -ForegroundColor white
Write-Host " Operating System: " -ForegroundColor yellow -NoNewline
Write-Host $productname.ProductName $currentversion.ReleaseId -ForegroundColor white
Write-Host " PC Name: " -ForegroundColor yellow -NoNewline
Write-Host $env:COMPUTERNAME -ForegroundColor white
Write-Host " Username: " -ForegroundColor yellow -NoNewline
Write-Host $env:USERNAME -ForegroundColor white
Write-Host " Domain: " -ForegroundColor yellow -NoNewline
Write-Host $env:USERDNSDOMAIN -ForegroundColor white
Write-Host
while ($confirmationpowersch -ne "n" -and $confirmationpowersch -ne "y") {
 $confirmationpowersch = Read-Host "Set PowerScheme to maximum performance? [y/n]"
}
while ($confirmationappremoval -ne "n" -and $confirmationappremoval -ne "y") {
	$confirmationappremoval = Read-Host "Remove all Windows Store apps except the Calculator, Photos, StickyNotes, and the Windows Store? [y/n]"
}
while ($confirmationchocoinstall -ne "n" -and $confirmationchocoinstall -ne "y") {
 $confirmationchocoinstall = Read-Host "Install Chocolatey and choose packages? [y/n]"
}
if ($confirmationchocoinstall -eq "y") {
	$chocolist = Read-Host "Specify Chocolatey packages to install separeted by spaces"
}
while ($confirmationonedrive -ne "n" -and $confirmationonedrive -ne "y") {
	$confirmationonedrive = Read-Host "Remove all traces of OneDrive? BE CAREFUL [y/n]"
}
Write-Host
Write-Host "Maximum PowerScheme: [$($confirmationpowersch)]"
Write-Host "App Removal: [$($confirmationappremoval)]"
Write-Host "Choco install: [$($confirmationchocoinstall)]"
Write-Host "OneDrive Removal: [$($confirmationonedrive)]"
Write-Host
Write-Host "Windows 10 De-Bloat Script will now run"
Write-Host
while ($confirmationfull -ne "n" -and $confirmationfull -ne "y") {
	$confirmationfull = Read-Host "Continue? [y/n]"
} if ($confirmationfull -ne "y") {
	Clear-Host
	exit
}
# Change Windows PowerScheme to maximum performance
if ($confirmationpowersch -eq "y") {
	$currScheme = powercfg /LIST | Select-String "High performance"
	$currScheme = $currScheme -split (" ")
	powercfg -SetActive $currScheme[3]
}
# Chocolatey install
if ($confirmationchocoinstall -eq "y") {
	Write-Host "Installing Chocolatey, specified packages" -ForegroundColor yellow
	Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	choco feature enable -n=allowGlobalConfirmation
	choco feature disable -n=checksumFiles
	$chocotobeinstalled = $chocolist.Replace(' ', ';').Replace(';;', ';')
	choco install $chocotobeinstalled
}
# Registry changes
$services = @(
	"diagnosticshub.standardcollector.service"
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
)
foreach ($service in $services) {
	Write-Host "Stopping $service"
	Stop-Service -Name $service
	Write-Host "Disabling $service"
	Get-Service -Name $service | Set-Service -StartupType Disabled
}
$Keys = @(
	"HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
	"HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
	"HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
	"HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
	"HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
	"HKCR:\Extensions\ContractId\Windows.File\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
	"HKCR:\Extensions\ContractId\Windows.Launch\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
	"HKCR:\Extensions\ContractId\Windows.Launch\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
	"HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
	"HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
	"HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
	"HKCR:\Extensions\ContractId\Windows.PreInstalledConfigTask\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
	"HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
	"HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
	"HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
	"HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
	"HKCR:\Extensions\ContractId\Windows.ShareTarget\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
	"HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
	"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
	"HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
)
ForEach ($Key in $Keys) {
	Write-Host "Removing $Key from registry"
	Remove-Item $Key -Recurse
}
$appsToRemove = @("Microsoft Edge", "Microsoft Store", "Mail")
foreach ($app in $appsToRemove) {
	((New-Object -Com Shell.Application).Namespace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | Where-Object { $_.Name -eq $app }).Verbs() | Where-Object { $_.Name.Replace('&', '') -match 'Unpin from taskbar' } | ForEach-Object { $_.DoIt(); $exec = $true } > $null 2>&1
}
Get-ScheduledTask XblGameSaveTaskLogon | Disable-ScheduledTask
Get-ScheduledTask XblGameSaveTask | Disable-ScheduledTask
Get-ScheduledTask Consolidator | Disable-ScheduledTask
Get-ScheduledTask UsbCeip | Disable-ScheduledTask
Get-ScheduledTask DmClient | Disable-ScheduledTask
Get-ScheduledTask DmClientOnScenarioDownload | Disable-ScheduledTask
Get-ScheduledTask Microsoft-Windows-DiskDiagnosticDataCollector | Disable-ScheduledTask
Get-ScheduledTask Proxy | Disable-ScheduledTask
Get-ScheduledTask ProgramDataUpdater | Disable-ScheduledTask
Get-ScheduledTask QueueReporting | Disable-ScheduledTask
Get-ScheduledTask Microsoft Compatibility Appraiser | Disable-ScheduledTask
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo"
New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\CloudContent"
New-Item -Path "HKCU:\Software\Microsoft\Siuf\Rules"
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "Serialize" -Type DWord -Value 0
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" -Name "StartupDelayInMSec" -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "NoTileApplicationNotification " -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SoftLandingEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoUseStoreOpenWith" -Type DWord -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Type DWord -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCortanaButton​" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Type DWord -Value 1
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -Type DWord -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\SYSTEM\Maps" -Name "AutoUpdateEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type String -Value "Deny"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic" -Name "FirstRunSucceeded" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "AllowSearchToUseLocation" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" -Name "AllowWindowsInkWorkspace" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "AllowOnlineTips" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWeb" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" -Name "AllowBuildPreview" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "AutoConnectAllowedOEM" -Type Dword -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "Value" -Type Dword -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "WiFISenseAllowed" -Type Dword -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableSmartScreen" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" -Name "EnabledV9" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0
# Remove all Windows store apps except WindowsStore, Calculator Photos and StickyNotes
if ($confirmationappremoval -eq "y") {
	Write-Host "Removing all Windows store apps except the Windows Store, Calculator, SitckyNotes, and Photos..." -ForegroundColor yellow
	Get-AppxPackage -AllUsers | Where-Object { $_.Name -notlike "*Bio*" } | Where-Object { $_.Name -notlike "*Microsoft.WindowsStore*" } | Where-Object { $_.Name -notlike "*Microsoft.WindowsCalculator*" } | Where-Object { $_.Name -notlike "*Microsoft.Windows.Photos*" } | Where-Object { $_.Name -notlike "*.NET*" } | Where-Object { $_.Name -notlike "*.VCLibs*" } | Where-Object { $_.Name -notlike "*Sticky*" } | Remove-AppxPackage -ErrorAction 'silentlycontinue'
	Get-AppxProvisionedPackage -Online | Where-Object { $_.packagename -notlike "*Bio*" } | Where-Object { $_.packagename -notlike "*Microsoft.WindowsStore*" } | Where-Object { $_.packagename -notlike "*Microsoft.WindowsCalculator*" } | Where-Object { $_.packagename -notlike "*Microsoft.Windows.Photos*" } | Where-Object { $_.Name -notlike "*.NET*" } | Where-Object { $_.Name -notlike "*.VCLibs*" } | Where-Object { $_.Name -notlike "*Sticky*" } | Remove-AppxProvisionedPackage -Online | Out-Null -ErrorAction 'silentlycontinue'
}
# Remove OneDrive
if ($confirmationonedrive -eq "y") {
	Write-Host "Disabling and removing OneDrive..." -ForegroundColor yellow
	taskkill.exe /F /IM "OneDrive.exe"
	Write-Host "Remove OneDrive..."
	if (Test-Path "$env:systemroot\System32\OneDriveSetup.exe") {
		& "$env:systemroot\System32\OneDriveSetup.exe" /uninstall
	}
	if (Test-Path "$env:systemroot\SysWOW64\OneDriveSetup.exe") {
		& "$env:systemroot\SysWOW64\OneDriveSetup.exe" /uninstall
	}
	Write-Host "Disable OneDrive via Group Policies..."
	Set-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" "DisableFileSyncNGSC" 1 -ErrorAction 'silentlycontinue'
	Write-Host "Removing OneDrive leftovers..."
	Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:localappdata\Microsoft\OneDrive"
	Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:programdata\Microsoft OneDrive"
	Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "C:\OneDriveTemp"
	Write-Host "Removing OneDrive from explorer sidebar..."
	New-PSDrive -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" -Name "HKCR"
	mkdir -Force "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
	Set-ItemProperty "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
	mkdir -Force "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
	Set-ItemProperty "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
	Remove-PSDrive "HKCR"
	Write-Host "Removing OneDrive run option for new users..."
	reg load "hku\Default" "C:\Users\Default\NTUSER.DAT"
}
taskkill /f /im explorer.exe
Remove-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore' -Recurse -Force
Start-Process explorer.exe
while ($confirmationreboot -ne "n" -and $confirmationreboot -ne "y") {
	$confirmationreboot = Read-Host "Reboot is recommended reboot this PC now? [y/n]"
} if ($confirmationreboot -eq "y") {
	Restart-Computer
	exit
}
