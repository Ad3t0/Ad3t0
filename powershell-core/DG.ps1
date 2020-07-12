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
$error.Clear()
$encT = "Hb1CgFxz0pTkt/TT+yltibW1UbsRdvMWLLA+IbrcMlv/reOb5NY5MoBg1mBkMjC2"
$encURL = "n0Vjuw9cTlCvJToeEtOM63imqi8ORuC3atEV6NatngC3S0HwEoaGuyazquulITtAeXKD196Tr792FSgHTTTRTuhjc8Q52+NY0ylWkp2NcHKu6mdyTfVOcNrQ7bmKgpfu"
while (!($decT)) {
	$pass = Read-Host -AsSecureString "Password"
	$pass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass))
	$decT = Decrypt-String -Encrypted $encT -Passphrase $pass
	$decURL = Decrypt-String -Encrypted $encURL -Passphrase $pass
}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "token $($decT)")
$headers.Add("Accept", "application/vnd.github.v3.raw")
$Script = Invoke-RestMethod "$($decURL)DG.ps1" -Headers $headers
Invoke-Expression $Script