if (!([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544"))) {
    Write-Warning "Powershell is not running as Administrator. Exiting..."
    Start-Sleep 3
    Return
}
if (!(Test-Path -Path "C:\Program Files\7-Zip\7z.exe")) {
    ""
    Write-Host "Downloading and installing 7zip..." -ForegroundColor Yellow
    ""
    $url = "https://www.7-zip.org/a/7z1900-x64.exe"
    $output = "$($env:TEMP)\7z1900-x64.exe"
    Invoke-WebRequest -Uri $url -OutFile $output
    ."$($env:TEMP)\7z1900-x64.exe" /S
    Wait-Process -Name 7z1900-x64
}
""
Write-Host "Adding Windows Defender exclusions..." -ForegroundColor Yellow
""
Add-MpPreference -ExclusionPath "$($env:TEMP)\RDPWrap-v1.6.2.zip"
Add-MpPreference -ExclusionPath "$($env:TEMP)\autoupdate.zip"
Add-MpPreference -ExclusionPath "C:\Program Files\RDP Wrapper\"
Add-MpPreference -ExclusionPath "C:\Program Files\RDP Wrapper\rdpwrap.dll"
Add-MpPreference -ExclusionProcess rdpwrap.dll
Start-Sleep 2
""
Write-Host "Downloading RDPWrap-v1.6.2.zip..." -ForegroundColor Yellow
""
$url = "https://github.com/stascorp/rdpwrap/releases/download/v1.6.2/RDPWrap-v1.6.2.zip"
$output = "$($env:TEMP)\RDPWrap-v1.6.2.zip"
Invoke-WebRequest -Uri $url -OutFile $output
""
Write-Host "Downloading autoupdate.zip..." -ForegroundColor Yellow
""
$url = "https://github.com/asmtron/rdpwrap/raw/master/autoupdate.zip"
$output = "$($env:TEMP)\autoupdate.zip"
Invoke-WebRequest -Uri $url -OutFile $output
""
Write-Host "Extracting RDPWrap-v1.6.2.zip..." -ForegroundColor Yellow
""
."C:\Program Files\7-Zip\7z.exe" x "$($env:TEMP)\RDPWrap-v1.6.2.zip" -o"C:\Program Files\RDP Wrapper" -aoa
""
Write-Host "Extracting autoupdate.zip..." -ForegroundColor Yellow
""
."C:\Program Files\7-Zip\7z.exe" x "$($env:TEMP)\autoupdate.zip" -o"C:\Program Files\RDP Wrapper" -aoa
""
Write-Host "Installing RDPWrapper..." -ForegroundColor Yellow
""
."C:\Program Files\RDP Wrapper\RDPWInst.exe" -i -o
""
Write-Host "Updating RDPWrapper..." -ForegroundColor Yellow
""
cmd /c "C:\Program Files\RDP Wrapper\autoupdate.bat"
while ($disableUpdatesConfirm -ne "n" -and $disableUpdatesConfirm -ne "y") {
    $disableUpdatesConfirm = Read-Host "Disable Windows Updates? [y/n]"
}
if ($disableUpdatesConfirm -eq "y") {
    ""
    Write-Host "Stopping Windows Update Service..." -ForegroundColor Yellow
    ""
    Stop-Service wuauserv
    ""
    Write-Host "Disabling Windows Update Service..." -ForegroundColor Yellow
    ""
    Set-Service wuauserv -StartupType Disabled
}
""
Write-Host "RDPWrapper Install Complete" -ForegroundColor Green
""