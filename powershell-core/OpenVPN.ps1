#############################################
#	Title:      OpenVPN					    #
#	Creator:	Ad3t0	                    #
#	Date:		04/10/2019             	    #
#############################################
$ver = "1.5.5"
$text1 = @'
     _       _ _____ _    ___
    / \   __| |___ /| |_ / _ \
   / _ \ / _` | |_ \| __| | | |
  / ___ \ (_| |___) | |_| |_| |
 /_/   \_\__,_|____/ \__|\___/
'@
$text2 = "       OpenVPN"
$text3 = "        Version: "
Write-Host $text1
Write-Host $text2 -ForegroundColor Yellow
Write-Host $text3 -ForegroundColor Gray -NoNewline
Write-Host $ver -ForegroundColor Green
if (!(Test-Path -Path "$($env:ProgramFiles)\OpenVPN\config\H1.ovpn"))
{ $user = Read-Host "Username"
	$pass = Read-Host "Password"
	Clear-Host
	Write-Host $text1
	Write-Host $text2 -ForegroundColor Yellow
	Write-Host $text3 -ForegroundColor Gray -NoNewline
	Write-Host $ver -ForegroundColor Green
	if (!(Test-Path -Path "C:\ProgramData\chocolatey\choco.exe"))
	{
		Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
		choco feature enable -n=allowGlobalConfirmation
		choco feature disable -n=checksumFiles
	}
	choco install openvpn megatools
	Remove-Item -Path "$($env:ProgramFiles)\OpenVPN\config\client.ovpn"
	Remove-Item -Path "$($env:ProgramFiles)\OpenVPN\config\H1.ovpn"
	megaget --path "$($env:ProgramFiles)\OpenVPN\config" -u $user -p $pass "/Root/VPN/H1.ovpn"
	megaget --path "$($env:ProgramFiles)\OpenVPN\config" -u $user -p $pass "/Root/VPN/H2-49865.ovpn"
}
. "$($env:ProgramFiles)\OpenVPN\bin\openvpn-gui.exe"

