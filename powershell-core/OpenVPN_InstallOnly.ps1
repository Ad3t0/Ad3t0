if ([System.Environment]::OSVersion.Version.Major -ge 6.2) {
	if (!(Test-Path -Path "C:\Program Files\OpenVPN\bin\openvpn.exe")) {
		$url = "https://swupdate.openvpn.org/community/releases/openvpn-install-2.4.8-I602-Win10.exe"
		$output = "$($env:TEMP)\openvpn-install-2.4.8-I602-Win10.exe"
		Invoke-WebRequest -Uri $url -OutFile $output
		.$output /S /SELECT_SHORTCUTS=0
		Wait-Process -Name "openvpn-install-2.4.8-I602-Win10"
	}
}
else {
	if (!(Test-Path -Path "C:\ProgramData\chocolatey\choco.exe")) {
		Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
		choco feature enable -n=allowGlobalConfirmation
		choco feature disable -n=checksumFiles
	}
	if (!(Test-Path -Path "C:\Program Files\OpenVPN\bin\openvpn.exe")) {
		choco install openvpn
	}
}
$url = "ftp://ad3t0.ddns.net/VPN/$($DOMAIN.Domain).ovpn"
$output = "C:\Program Files\OpenVPN\config\$($DOMAIN.Domain).ovpn"
Invoke-WebRequest -Uri $url -OutFile $output
$DOMAIN = Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters -Name "Domain"
$DOMAINSplit = $DOMAIN.Domain.Split(".").ToUpper()
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OpenVPN-GUI" -Value "C:\Program Files\OpenVPN\bin\openvpn-gui.exe" -ErrorAction SilentlyContinue
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$([environment]::GetFolderPath("Desktop"))\Connect VPN to $($DOMAINSplit[0]).lnk")
$Shortcut.TargetPath = """C:\Program Files\OpenVPN\bin\openvpn-gui.exe"""
$Shortcut.Arguments = "--connect $($DOMAIN.Domain).ovpn --show_script_window 0"
$Shortcut.Save()
