$sls = Get-WmiObject -Query 'SELECT * FROM SoftwareLicensingService'
$sls.InstallProductKey('W269N-WFGWX-YVC9B-4J6C9-T83GX')
$sls.RefreshLicenseStatus()
Get-WindowsEdition -Online