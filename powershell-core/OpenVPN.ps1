#############################################
#	Title:      OpenVPN					    #
#	Creator:	Ad3t0	                    #
#	Date:		04/10/2019             	    #
#############################################
$ver = "1.5.9"
function Decrypt-String ($Encrypted, $Passphrase, $salt = "Ad3t049866", $init = "Ad3t0PASS") {
	if ($Encrypted -is [string]) {
		$Encrypted = [Convert]::FromBase64String($Encrypted)
	}
	$r = New-Object System.Security.Cryptography.RijndaelManaged
	$pass = [Text.Encoding]::UTF8.GetBytes($Passphrase)
	$salt = [Text.Encoding]::UTF8.GetBytes($salt)
	$r.Key = (New-Object Security.Cryptography.PasswordDeriveBytes $pass, $salt, "SHA1", 5).GetBytes(32)
	$r.IV = (New-Object Security.Cryptography.SHA1Managed).ComputeHash([Text.Encoding]::UTF8.GetBytes($init))[0..15]
	$d = $r.CreateDecryptor()
	$ms = New-Object IO.MemoryStream @(, $Encrypted)
	$cs = New-Object Security.Cryptography.CryptoStream $ms, $d, "Read"
	$sr = New-Object IO.StreamReader $cs
	Write-Output $sr.ReadToEnd()
	$sr.Close()
	$cs.Close()
	$ms.Close()
	$r.Clear()
}
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
$encURL = "GkNRDbdvqsKt49ugrqVnMSWWMLeJ9rqzc0nM+tFQyyhzt86vi0Z48AOYbBddxrivJBcdMVe/KXFlCBTZ7rwSYAwYMAib0DlzbJNQKkBf7dueU4/IYyMctJ7XApKWQ9Jf"
$pass = Read-Host "Password"
Clear-Host
Write-Host $text1
Write-Host $text2 -ForegroundColor Yellow
Write-Host $text3 -ForegroundColor Gray -NoNewline
Write-Host $ver -ForegroundColor Green
if ([System.Environment]::OSVersion.Version.Major -ge 6.2) {
	if (!(Test-Path -Path "C:\Program Files\OpenVPN\bin\openvpn.exe")) {
		$url = "https://swupdate.openvpn.org/community/releases/openvpn-install-2.4.8-I602-Win10.exe"
		$output = "$($env:TEMP)\openvpn-install-2.4.8-I602-Win10.exe"
		Invoke-WebRequest -Uri $url -OutFile $output
		."$($env:TEMP)\openvpn-install-2.4.8-I602-Win10.exe" /S /SELECT_SHORTCUTS=0
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
$decURL = Decrypt-String -Encrypted $encURL -Passphrase $pass
Invoke-WebRequest -Uri $decURL -UseBasicParsing
$webClient = New-Object System.Net.WebClient
$webClient.Encoding = [System.Text.Encoding]::UTF8
$webClient.DownloadFile($decURL, "$($env:ProgramFiles)\OpenVPN\config\H1.ovpn")
. "$($env:ProgramFiles)\OpenVPN\bin\openvpn-gui.exe"
