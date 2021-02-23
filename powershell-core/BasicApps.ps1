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
	choco install powershell googlechrome vcredist-all dotnetfx directx notepadplusplus 7zip revo-uninstaller
}
else {
	choco install powershell googlechrome vcredist-all dotnetfx directx dotnet3.5 javaruntime 7zip adobereader revo-uninstaller
}
