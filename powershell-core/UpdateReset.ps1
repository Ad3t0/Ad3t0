if (!([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544"))) {
    Write-Warning "Powershell is not running as Administrator. Exiting..."
    Start-Sleep 3
    Return
}
$arch = Get-WMIObject -Class Win32_Processor -ComputerName LocalHost | Select-Object AddressWidth
""
Write-Host "Stopping Windows Update Services..." -ForegroundColor Yellow
""
Stop-Service -Name BITS
""
Write-Host "BITS Service Stopped" -ForegroundColor Yellow
""
Stop-Service -Name wuauserv
""
Write-Host "wuauserv Service Stopped" -ForegroundColor Yellow
""
Stop-Service -Name appidsvc
""
Write-Host "appidsvc Service Stopped" -ForegroundColor Yellow
""
Stop-Service -Name cryptsvc
""
Write-Host "cryptsvc Service Stopped" -ForegroundColor Yellow
""
""
Write-Host "Removing QMGR Data file..." -ForegroundColor Yellow
""
Remove-Item "$env:allusersprofile\Application Data\Microsoft\Network\Downloader\qmgr*.dat" -ErrorAction SilentlyContinue
""
Write-Host "Renaming the Software Distribution and CatRoot Folder..." -ForegroundColor Yellow
""
Rename-Item $env:systemroot\SoftwareDistribution SoftwareDistribution.bak -ErrorAction SilentlyContinue
Rename-Item $env:systemroot\System32\Catroot2 catroot2.bak -ErrorAction SilentlyContinue
""
Write-Host "Removing old Windows Update log..." -ForegroundColor Yellow
""
Remove-Item $env:systemroot\WindowsUpdate.log -ErrorAction SilentlyContinue
""
Write-Host "Resetting the Windows Update Services to defualt settings..." -ForegroundColor Yellow
""
sc.exe sdset bits "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
sc.exe sdset wuauserv "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
Set-Location $env:systemroot\system32
""
Write-Host "Registering some DLLs..." -ForegroundColor Yellow
""
regsvr32.exe /s atl.dll
regsvr32.exe /s urlmon.dll
regsvr32.exe /s mshtml.dll
regsvr32.exe /s shdocvw.dll
regsvr32.exe /s browseui.dll
regsvr32.exe /s jscript.dll
regsvr32.exe /s vbscript.dll
regsvr32.exe /s scrrun.dll
regsvr32.exe /s msxml.dll
regsvr32.exe /s msxml3.dll
regsvr32.exe /s msxml6.dll
regsvr32.exe /s actxprxy.dll
regsvr32.exe /s softpub.dll
regsvr32.exe /s wintrust.dll
regsvr32.exe /s dssenh.dll
regsvr32.exe /s rsaenh.dll
regsvr32.exe /s gpkcsp.dll
regsvr32.exe /s sccbase.dll
regsvr32.exe /s slbcsp.dll
regsvr32.exe /s cryptdlg.dll
regsvr32.exe /s oleaut32.dll
regsvr32.exe /s ole32.dll
regsvr32.exe /s shell32.dll
regsvr32.exe /s initpki.dll
regsvr32.exe /s wuapi.dll
regsvr32.exe /s wuaueng.dll
regsvr32.exe /s wuaueng1.dll
regsvr32.exe /s wucltui.dll
regsvr32.exe /s wups.dll
regsvr32.exe /s wups2.dll
regsvr32.exe /s wuweb.dll
regsvr32.exe /s qmgr.dll
regsvr32.exe /s qmgrprxy.dll
regsvr32.exe /s wucltux.dll
regsvr32.exe /s muweb.dll
regsvr32.exe /s wuwebv.dll
""
Write-Host "Removing WSUS client settings..." -ForegroundColor Yellow
""
Remove-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate -Name AccountDomainSid -ErrorAction SilentlyContinue
Remove-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate -Name PingID -ErrorAction SilentlyContinue
Remove-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate -Name SusClientId -ErrorAction SilentlyContinue
Remove-ItemProperty HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU -Name UseWUServer -ErrorAction SilentlyContinue
Remove-ItemProperty HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate -Name WUServer -ErrorAction SilentlyContinue
Remove-ItemProperty HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate -Name DisableWindowsUpdateAccess -ErrorAction SilentlyContinue
Remove-ItemProperty "HKLM:\SYSTEM\Internet Communication Management\Internet Communication" -Name DisableWindowsUpdateAccess -ErrorAction SilentlyContinue
Remove-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate -Name DisableWindowsUpdateAccess -ErrorAction SilentlyContinue
New-Item -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate -ErrorAction SilentlyContinue
New-Item -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU -ErrorAction SilentlyContinue
New-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU -Name NoAutoRebootWithLoggedOnUsers -Value 1 -ErrorAction SilentlyContinue
New-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU -Name NoAutoUpdate -Value 1 -ErrorAction SilentlyContinue
""
Write-Host "Resetting the WinSock..." -ForegroundColor Yellow
""
netsh winsock reset
netsh winhttp reset proxy
""
Write-Host "Delete all BITS jobs..." -ForegroundColor Yellow
""
Get-BitsTransfer | Remove-BitsTransfer
""
Write-Host "Attempting to install the Windows Update Agent..." -ForegroundColor Yellow
""
if ($arch -eq 64) {
    wusa Windows8-RT-KB2937636-x64 /quiet
}
else {
    wusa Windows8-RT-KB2937636-x86 /quiet
}
""
Write-Host "Starting Windows Update Services..." -ForegroundColor Yellow
""
sc.exe config wuauserv start= delayed-auto
sc.exe config BITS start= delayed-auto
Start-Service -Name BITS
Start-Service -Name wuauserv
Start-Service -Name appidsvc
Start-Service -Name cryptsvc
""
Write-Host "Forcing discovery..." -ForegroundColor Yellow
""
wuauclt /resetauthorization /detectnow
""
Write-Host "Process complete. Please reboot your computer." -ForegroundColor Green
""
while ($rebootConfirm -ne "n" -and $rebootConfirm -ne "y") {
    $rebootConfirm = Read-Host "Reboot now? [y/n]"
}
if ($rebootConfirm -eq "y") {
    Restart-Computer
}