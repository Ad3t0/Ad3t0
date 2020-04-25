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
$encT = "b3Mi+G5kF+2ujmxedqiYxzKvvgQROtYwm+WAHUFrK67PHTILwrLyr0lqUZHifadw"
$encURL = "SekvfcmJCzw8G3sKq+9z5qj4icmfGYQWmhReBCmHEiTx7QPsD3woZSGKAycsd7gMnwul0dSujQ7xgTO/nHMazl1ouSKzkgWfbxHnDc8CrMd9z1owFY9RZ7cHqQzWM0n3"
$pass = Read-Host -AsSecureString "Password"
$pass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass))
$decT = Decrypt-String -Encrypted $encT -Passphrase $pass
$decURL = Decrypt-String -Encrypted $encURL -Passphrase $pass
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "token $($decT)")
$headers.Add("Accept", "application/vnd.github.v3.raw")
$Script = Invoke-RestMethod "$($decURL)WINC.ps1" -Headers $headers
Invoke-Expression $Script