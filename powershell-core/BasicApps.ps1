if (!(Test-Path -Path "C:\ProgramData\chocolatey\choco.exe")) {
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	choco feature enable -n=allowGlobalConfirmation
	choco feature disable -n=checksumFiles
}
choco install firefox googlechrome vcredist-all dotnetfx directx adobereader
