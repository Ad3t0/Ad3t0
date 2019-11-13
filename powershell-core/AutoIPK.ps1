$ver = "1.0.0"
$checkLicenseStatus = cscript C:\Windows\System32\slmgr.vbs /dli
if ($checkLicenseStatus -like "*Licensed*")
{
	Write-Host "Windows is already licensed exiting..."
}
else
{
	$user = Read-Host "Username"
	$pass = Read-Host "Password"
	if (!(Test-Path -Path "C:\ProgramData\chocolatey\choco.exe"))
	{
		Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
		choco feature enable -n=allowGlobalConfirmation
		choco feature disable -n=checksumFiles
	}
	choco install megatools
	megaget --path $env:TEMP -u $user -p $pass "/Root/Keys/Windows10Pro.txt"
	Sleep 1
	[string[]]$lkArray = Get-Content -Path "$($env:TEMP)\Windows10Pro.txt"
	$lkAttempt = 0
	while ($checkLicenseStatus -like "*Notification*" -and $lkAttempt -le $lkArray.Count)
	{
		Write-Host "Windows Is Not Licensed"
		cscript C:\Windows\System32\slmgr.vbs /ipk $lkArray[$lkAttempt]
		Sleep 2
		cscript C:\Windows\System32\slmgr.vbs /ato
		Sleep 2
		$lkAttempt = $lkAttempt += 1
		$checkLicenseStatus = cscript C:\Windows\System32\slmgr.vbs /dli
	}
	if ($checkLicenseStatus -like "*Licensed*")
	{
		Remove-Item -Path "$($env:TEMP)\Windows10Pro.txt"
		Write-Host "Windows was licensed successfully!"
	}
	else
	{
		Write-Host "Windows licensing failed"
	}
}
