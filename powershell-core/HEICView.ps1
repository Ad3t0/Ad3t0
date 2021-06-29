[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
if (!(Test-Path -Path "$($env:TEMP)\QuickLook-3.6.11.msi" -or Test-Path -Path "$($env:LOCALAPPDATA)\Programs\QuickLook\QuickLook.exe")) {
    $url = "https://github.com/QL-Win/QuickLook/releases/download/3.6.11/QuickLook-3.6.11.msi"
    $output = "$($env:TEMP)\QuickLook-3.6.11.msi"
    Invoke-WebRequest -Uri $url -OutFile $output
    Start-Process C:\Windows\System32\msiexec.exe -ArgumentList "/i $($env:TEMP)\QuickLook-3.6.11.msi /qn" -Wait
}
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/DanysysTeam/PS-SFTA/master/SFTA.ps1'))
Register-FTA "$($env:LOCALAPPDATA)\Programs\QuickLook\QuickLook.exe" .heic
