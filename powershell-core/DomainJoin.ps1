Clear-Host
Clear-Host
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
if ($env:USERDNSDOMAIN) {
	""
	Write-Warning "This device is already joined to $($env:USERDNSDOMAIN). Exiting..."
	""
	Return
}
""
$DOMAIN = Read-Host "Enter domain name"
$osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
if ($osInfo.ProductType -eq 1) {
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
}
else {
	$pcName = Read-Host "This device is a server. Please manually enter the computer name"
}
$domainJoinSuccess = $False
$domainPingSuccess = $False
while ($domainPingSuccess -eq $False) {
	$error.Clear()
	Test-Connection $DOMAIN -Count 1
	if ($error) {
		""
		Write-Warning "Domain $($DOMAIN) could not be reached."
		""
		while ($setManualDNSConfirm -ne "n" -and $setManualDNSConfirm -ne "y") {
			$setManualDNSConfirm = Read-Host "Set DNS server for $($DOMAIN) manually? [y/n]"
		}
		if ($setManualDNSConfirm -eq "y") {
			while ($retryDNSpingConfirm -ne "n" -and $dnsContactSuccess -ne $True) {
				""
				$dnsServer = Read-Host "Enter DNS server"
				$error.Clear()
				Test-Connection $dnsServer -Count 1
				if ($error) {
					""
					Write-Warning "Specified DNS server $($dnsServer) could not be reached."
					""
					$retryDNSpingConfirm = Read-Host "Try again? [y/n]"
					if ($retryDNSpingConfirm -eq "n") {
						Return
					}
				}
				else {
					$dnsContactSuccess = $True
				}
			}
			if ($setManualDNSConfirm -eq "n") {
				Return
			}
			$ipV4 = Test-Connection -ComputerName $env:COMPUTERNAME -Count 1
			$netAdapters = Get-WmiObject win32_networkadapterconfiguration -Filter 'ipenabled = "true"'
			$primaryAdapter1 = $netAdapters | Where-Object { $_.IPAddress -eq $ipV4.IPV4Address.IPAddressToString }
			$primaryAdapter2 = Get-NetAdapter | Where-Object { $_.InterfaceDescription -eq $primaryAdapter1.Description }
			Set-DnsClientServerAddress -InterfaceIndex $primaryAdapter2.ifIndex -ServerAddresses ($dnsServer)
			$error.Clear()
			Test-Connection $DOMAIN -Count 1
			if ($error) {
				""
				Write-Warning "After manually setting DNS servers domain $($DOMAIN) still could not be reached. Exiting..."
				""
				Return
			}
		}
		else {
			Return
		}
	}
	else {
		$domainPingSuccess = $true
	}
}
while ($domainJoinSuccess -eq $False) {
	$error.Clear()
	if ($env:COMPUTERNAME -eq $pcName) {
		Add-Computer -DomainName $DOMAIN -Credential "Administrator"
	}
	else {
		Add-Computer -NewName $pcName -DomainName $DOMAIN -Credential "Administrator"
	}
	Start-Sleep 2
	if ($error) {
		""
		Write-Warning "Domain join failed. Incorrect administrator credentials or the domain $($DOMAIN) could not be reached."
		""
	}
	else {
		$domainJoinSuccess = $true
		""
		Write-Host "Device has been named $($pcName) and joined to $($DOMAIN)" -ForegroundColor Green
		""
	}
}
while ($rebootConfirm -ne "n" -and $rebootConfirm -ne "y") {
	$rebootConfirm = Read-Host "Reboot now? [y/n]"
}
if ($rebootConfirm -eq "y") {
	Restart-Computer
}