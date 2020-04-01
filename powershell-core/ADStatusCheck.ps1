$scr = ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/chrisdee/Scripts/master/PowerShell/Working/AD/GetADForestHealthStatusReport.ps1'))


$scr | Out-File -FilePath $env:TEMP\GetADForestHealthStatusReport.ps1


.$env:TEMP\GetADForestHealthStatusReport.ps1 -ReportFile