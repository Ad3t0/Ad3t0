Clear-Host
""
$DOMAIN = Read-Host "Enter domain name"
$DOMAINShort = $DOMAIN
if ($DOMAIN -like "*.*") {
	$DOMAINSplit = $DOMAIN.Split(".")
	$DOMAINShort = $DOMAINSplit[0]
}
if ($DOMAINShort.length -gt 4) {
	$DOMAINShort = $DOMAINShort.Substring(0, 4)
}
$DOMAINShort = $DOMAINShort.ToUpper()
$hwInfo = Get-CimInstance -ClassName Win32_ComputerSystem
$hwInfo = $hwInfo.Manufacturer
if ($hwInfo.length -gt 4) {
	$hwInfo = $hwInfo.Substring(0, 4)
}
$hwInfo = $hwInfo.ToUpper()
$getMac = Get-WmiObject Win32_NetworkAdapter -Filter 'NetConnectionStatus=2'
$lastOfMac = $getMac.MACAddress -split ":"
$lastOfMac = "$($lastOfMac[4])$($lastOfMac[5])"
$pcName = "$($DOMAINShort)-$($hwInfo)-$($lastOfMac)"
$domainJoinSuccess = $False
while ($domainJoinSuccess -eq $False) {
	$error.Clear()
	Add-Computer -NewName $pcName -DomainName $DOMAIN -Credential "Administrator"
	if (!($error)) {
		$domainJoinSuccess = $true
		""
		Write-Host "Device has been renamed to $($pcName) and joined to $($DOMAIN)" -ForegroundColor Green
		""
	}
}
while ($rebootConfirm -ne "n" -and $rebootConfirm -ne "y") {
	$rebootConfirm = Read-Host "Reboot now? [y/n]"
}
if ($rebootConfirm -eq "y") {
	Restart-Computer
}