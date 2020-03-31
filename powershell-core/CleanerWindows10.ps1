$ver = "3.0.0"
if ((Get-WmiObject win32_operatingsystem).Name -notlike "*Windows 10*") {
 Write-Warning "Operating system is not Windows 10..."
	Read-Host "The script will now exit..."
	exit
} $systemmodel = wmic computersystem get model /VALUE
$systemmodel = $systemmodel -replace ('Model=', '')
$currentversion = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ReleaseId" -ErrorAction SilentlyContinue
$productname = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ProductName" -ErrorAction SilentlyContinue
function header {
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
} header
New-Item -Path $env:TEMP -Name "powershell-bin" -ItemType "directory" -Force > $null 2>&1
Set-Location "$($env:TEMP)\powershell-bin"
 while ($initialsetting -ne "1" -and $initialsetting -ne "2") {
 Clear-Host
	header
	if (([string]::IsNullOrEmpty($initialsetting)) -ne $true) {
		if ($initialsetting -ne "1" -and $initialsetting -ne "2") {
			Write-Warning "Invalid option"
		}
	}
	Write-Host "----------------------------------------"
	Write-Host
	Write-Host " 1 - Basic"
	Write-Host " 2 - Advanced"
	Write-Host
	$initialsetting = Read-Host -Prompt "Input option"
} while ($confirmationpowersch -ne "n" -and $confirmationpowersch -ne "y") {
 $confirmationpowersch = Read-Host "Set PowerScheme to maximum performance? [y/n]"
} while ($confirmationstartmenu -ne "n" -and $confirmationstartmenu -ne "y") {
 $confirmationstartmenu = Read-Host "Unpin all StartMenu icons? [y/n]"
	while ($confirmationappremoval -ne "n" -and $confirmationappremoval -ne "y") {
		$confirmationappremoval = Read-Host "Remove all Windows Store apps except the Calculator, Photos, StickyNotes, and the Windows Store? [y/n]"
	}
} while ($confirmationchocoinstall -ne "n" -and $confirmationchocoinstall -ne "y") {
 $confirmationchocoinstall = Read-Host "Install Chocolatey and choose packages? [y/n]"
} if ($initialsetting -eq "2") {
 while ($confirmationonedrive -ne "n" -and $confirmationonedrive -ne "y") {
		$confirmationonedrive = Read-Host "Remove all traces of OneDrive? [y/n]"
	}
	while ($confirmationwallpaperq -ne "n" -and $confirmationwallpaperq -ne "y") {
		$confirmationwallpaperq = Read-Host "Increase desktop wallpaper compression to max quality? [y/n]"
	}
	while ($confirmationshowfileex -ne "n" -and $confirmationshowfileex -ne "y") {
		$confirmationshowfileex = Read-Host "Show file extension in File Explorer? [y/n]"
	}
	while ($confirmationshowhiddenfiles -ne "n" -and $confirmationshowhiddenfiles -ne "y") {
		$confirmationshowhiddenfiles = Read-Host "Show hidden files in File Explorer? [y/n]"
	}
	while ($confirmationrdp -ne "n" -and $confirmationrdp -ne "y") {
		$confirmationrdp = Read-Host "Enable Allow Remote Desktop Connections? [y/n]"
	}
	while ($confirmationwol -ne "n" -and $confirmationwol -ne "y") {
		$confirmationwol = Read-Host "Enable Allow Wake On LAN? [y/n]"
	}
	while ($confirmationhostsadb -ne "n" -and $confirmationhostsadb -ne "y") {
		$confirmationhostsadb = Read-Host "Download MVPS hosts for system wide ad blocking? [y/n]"
	}
} if ($confirmationchocoinstall -eq "y") {
 Write-Host
	Write-Host "A .txt file containing the Chocolatey packages to be installed will now open"
	Write-Host "edit, save and close the file separating each package name with a semicolon"
	Write-Host
	Read-Host "Press ENTER to open the chocolist.txt file"
	notepad.exe "$($env:TEMP)\powershell-bin\chocolist.txt"
	Read-Host "Press ENTER to continue after the chocolist.txt file has been saved"
} $chocolist = [IO.File]::ReadAllText("$($env:TEMP)\powershell-bin\chocolist.txt")
Write-Host
Write-Host "Maximum PowerScheme: [$($confirmationpowersch)]"
Write-Host "Unpin All StartMenu Icons: [$($confirmationstartmenu)]"
Write-Host "App Removal: [$($confirmationappremoval)]"
Write-Host "Choco install: [$($confirmationchocoinstall)]"
if ($initialsetting -eq "2") {
 Write-Host "OneDrive Removal: [$($confirmationonedrive)]"
	Write-Host "Wallpaper Max Quality: [$($confirmationwallpaperq)]"
	Write-Host "Show File Extensions: [$($confirmationshowfileex)]"
	Write-Host "Show Hidden Files: [$($confirmationshowhiddenfiles)]"
	Write-Host "Allow Remote Desktop: [$($confirmationrdp)]"
	Write-Host "Allow Wake On LAN: [$($confirmationwol)]"
	Write-Host "MVPS hosts File: [$($confirmationhostsadb)]"
} Write-Host
Write-Host "Windows 10 Setup Script will now run"
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
 Write-Host "Installing Chocolatey, specified packages, and all VCRedist Visual C++ versions..." -ForegroundColor yellow
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
	"ndu"
)
foreach ($service in $services) {
	Write-Output "Stopping $service"
	Stop-Service -Name $service
	Write-Output "Disabling $service"
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
	Write-Output "Removing $Key from registry"
	Remove-Item $Key -Recurse
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
	Get-AppxPackage -AllUsers | Where-Object { $_.Name -notlike "*Microsoft.WindowsStore*" } | Where-Object { $_.Name -notlike "*Microsoft.WindowsCalculator*" } | Where-Object { $_.Name -notlike "*Microsoft.Windows.Photos*" } | Where-Object { $_.Name -notlike "*.NET*" } | Where-Object { $_.Name -notlike "*.VCLibs*" } | Where-Object { $_.Name -notlike "*Sticky*" } | Remove-AppxPackage -ErrorAction 'silentlycontinue'
	Get-AppxProvisionedPackage -Online | Where-Object { $_.packagename -notlike "*Microsoft.WindowsStore*" } | Where-Object { $_.packagename -notlike "*Microsoft.WindowsCalculator*" } | Where-Object { $_.packagename -notlike "*Microsoft.Windows.Photos*" } | Where-Object { $_.Name -notlike "*.NET*" } | Where-Object { $_.Name -notlike "*.VCLibs*" } | Where-Object { $_.Name -notlike "*Sticky*" } | Remove-AppxProvisionedPackage -Online | Out-Null -ErrorAction 'silentlycontinue'
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
# Download MVPS hosts file and backup current hosts file
if ($confirmationonedrive -eq "y") {
 Write-Host "Backing up hosts file to $($env:SystemRoot)\System32\drivers\etc\hosts.bak" -ForegroundColor yellow
	Copy-Item "$($env:SystemRoot)\System32\drivers\etc\hosts" -Destination "$($env:SystemRoot)\System32\drivers\etc\hosts.bak"
	(New-Object Net.WebClient).DownloadString('http://winhelp2002.mvps.org/hosts.txt') | Out-File "$($env:SystemRoot)\System32\drivers\etc\hosts" -Force
}
# Finalize
taskkill /f /im explorer.exe
Remove-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore' -Recurse -Force
Start-Process explorer.exe
while ($confirmationreboot -ne "n" -and $confirmationreboot -ne "y") {
 $confirmationreboot = Read-Host "Reboot is recommended reboot this PC now? [y/n]"
} if ($confirmationreboot -eq "y") {
 Restart-Computer
} exit
