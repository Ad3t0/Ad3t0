if (!([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544"))) {
	Write-Warning "Powershell is not running as Administrator. Exiting..."
	Start-Sleep 3
	Return
}
if (!(Test-Path -Path "C:\ProgramData\chocolatey\choco.exe")) {
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	choco feature enable -n=allowGlobalConfirmation
	choco feature disable -n=checksumFiles
}

$osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
if ($osInfo.ProductType -ne 1) {
	choco install firefox googlechrome vcredist-all dotnetfx directx adobereader setdefaultbrowser
	SetDefaultBrowser.exe HKLM "Firefox-308046B0AF4A39CB"
}
else {
	""
	Write-Host "1 - Firefox"
	Write-Host "2 - Google Chrome"
	Write-Host "3 - Microsoft Edge"
	Write-Host "4 - Internet Explorer"
	""
	while ($confirmBrowser -ne "1" -and $confirmBrowser -ne "2" -and $confirmBrowser -ne "3" -and $confirmBrowser -ne "4") {
  $confirmBrowser = Read-Host "Select default browser. [1/2/3/4]"
	}
	choco install firefox vcredist-all dotnetfx directx notepadplusplus windirstat setdefaultbrowser
	if ($confirmBrowser -eq 1) {
		SetDefaultBrowser.exe HKLM "Firefox-308046B0AF4A39CB"
	}
	if ($confirmBrowser -eq 2) {
		SetDefaultBrowser.exe HKLM "Google Chrome.HEYY3KJOYOAJOPVCHWOFAPMTPI"
		SetDefaultBrowser.exe HKLM "Google Chrome"
	}
	if ($confirmBrowser -eq 3) {
		SetDefaultBrowser.exe HKLM Edge
	}
	if ($confirmBrowser -eq 4) {
		SetDefaultBrowser.exe HKLM IEXPLORE.EXE
	}
}
