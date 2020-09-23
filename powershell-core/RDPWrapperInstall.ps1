if (!([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544"))) {
    Write-Warning "Powershell is not running as Administrator. Exiting..."
    Start-Sleep 3
    Return
}
if (!(Test-Path -Path "C:\Program Files\7-Zip\7z.exe")) {
    $url = "https://www.7-zip.org/a/7z1900-x64.exe"
    $output = "$($env:TEMP)\7z1900-x64.exe"
    Invoke-WebRequest -Uri $url -OutFile $output
    ."$($env:TEMP)\7z1900-x64.exe" /S
    Wait-Process -Name 7z1900-x64
}
Add-MpPreference -ExclusionPath "$($env:TEMP)\RDPWrap-v1.6.2.zip"
Add-MpPreference -ExclusionPath "$($env:TEMP)\autoupdate.zip"
Add-MpPreference -ExclusionPath "C:\Program Files\RDP Wrapper\"
Add-MpPreference -ExclusionPath "C:\Program Files\RDP Wrapper\rdpwrap.dll"
Add-MpPreference -ExclusionProcess rdpwrap.dll
$url = "https://github.com/stascorp/rdpwrap/releases/download/v1.6.2/RDPWrap-v1.6.2.zip"
$output = "$($env:TEMP)\RDPWrap-v1.6.2.zip"
Invoke-WebRequest -Uri $url -OutFile $output
$url = "https://github.com/asmtron/rdpwrap/raw/master/autoupdate.zip"
$output = "$($env:TEMP)\autoupdate.zip"
Invoke-WebRequest -Uri $url -OutFile $output
."C:\Program Files\7-Zip\7z.exe" x "$($env:TEMP)\RDPWrap-v1.6.2.zip" -o"C:\Program Files\RDP Wrapper"
."C:\Program Files\7-Zip\7z.exe" x "$($env:TEMP)\autoupdate.zip" -o"C:\Program Files\RDP Wrapper"
."C:\Program Files\RDP Wrapper\RDPWInst.exe" -i -o
cmd /c "C:\Program Files\RDP Wrapper\autoupdate.bat"
