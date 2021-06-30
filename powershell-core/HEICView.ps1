if (!(Test-Path -Path "$($env:LOCALAPPDATA)\Programs\QuickLook\QuickLook.exe")) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Remove-Item -Path "$($env:TEMP)\QuickLook-3.6.11.msi" -ErrorAction SilentlyContinue
    $url = "https://github.com/QL-Win/QuickLook/releases/download/3.6.11/QuickLook-3.6.11.msi"
    $output = "$($env:TEMP)\QuickLook-3.6.11.msi"
    Invoke-WebRequest -Uri $url -OutFile $output
    Start-Process C:\Windows\System32\msiexec.exe -ArgumentList "/i $($env:TEMP)\QuickLook-3.6.11.msi /qn" -Wait
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/DanysysTeam/PS-SFTA/master/SFTA.ps1'))
    Register-FTA "$($env:LOCALAPPDATA)\Programs\QuickLook\QuickLook.exe" .heic
    Set-FTA "SFTA.QuickLook.heic" .heic
    ."$($env:LOCALAPPDATA)\Programs\QuickLook\QuickLook.exe"
    Move-Item -Path "$($env:USERPROFILE)\Desktop\QuickLook.lnk" -Destination "$($env:USERPROFILE)\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\QuickLook.lnk"
}
