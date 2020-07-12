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
$scr = ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/chrisdee/Scripts/master/PowerShell/Working/AD/GetADForestHealthStatusReport.ps1'))
$scr | Out-File -FilePath $env:TEMP\GetADForestHealthStatusReport.ps1
.$env:TEMP\GetADForestHealthStatusReport.ps1 -ReportFile
Start-Process "$($env:USERPROFILE)\forest_health_report_$($env:USERDNSDOMAIN).html"