# Windows 7, 8, 10 and Windows Server PowerShell Scripts
[![](https://i.imgur.com/bzG7kdD.png)](#)


### **Paste links into PowerShell**
## OpenVPN_Multi
#### Private OpenVPN with pulled config
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/OpenVPN_Multi.ps1'))
```
## ChocoInstall
#### Installs [Chocolatey](https://chocolatey.org/)
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/ChocoInstall.ps1'))
```
## BasicApps
#### Installs all VCRedist packages, DirectX, .Net 4.8, Firefox, Google Chrome, Adobereader
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/BasicApps.ps1'))
```
## MSOfficeInstall
#### Install MS Office
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/MSOfficeInstall.ps1'))
```
## DriverSearch
#### Google search with system model for drivers
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/DriverSearch.ps1'))
```
## DomainJoin
#### Join computer to specified domain with generated name
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/DomainJoin.ps1'))
```
## UpdateReset
#### Completely Resets Windows Update
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/UpdateReset.ps1'))
```
## ADStatusCheck
#### ADStatusCheck
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/ADStatusCheck.ps1'))
```
## PFMG
#### Profile Migration Utility
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/PFMG/master/PFMG.ps1'))
```
## PSS3B
#### Configures AWS and creates scheduled tasks for a weekly AWS S3 backup
```powershelld
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/PSS3B/master/PSS3B.ps1'))
```
## PortScan
#### Port scan local network
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/PortScan.ps1'))
```
## WINC
#### WINC
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/WINC.ps1'))
```
## DG
#### DG
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/DG.ps1'))
```
## WinSatFormal
#### Run a Windows PC Benchmark WinSat
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/WinSatFormal.ps1'))
```
## CredShow
#### Displays saved Windows credentials
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/CredShow.ps1'))
```
## GPOImport
#### GPO Import script
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/GPOImport.ps1'))
```
## WINRMgpupdate
#### Remote domain wide GPUpdate
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/WINRMgpupdate.ps1'))
```
## WINRMScript
#### Remote domain wide PowerShell Script
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/WINRMScript.ps1'))
```
## WiFiQR
#### Create a iOS camera readable Wi-Fi connect QR code using information from the currently connected Wi-Fi network
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/WiFiQR.ps1'))
```
## CleanerWindows10
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/CleanerWindows10.ps1'))
```
Each option can be selected individually within the script
- Basic
  - Disable Start Menu Bing search and application suggestions
  - Disable subscribed ads, location tracking, and advertiser ID
  - Disable resource intensive P2P update sharing
  - Disable Cortana, Ink Space and 3D Objects folder
  - Disable ALL Windows Telemetry and Online Tips/Ads
  - Disable Wi-Fi Sense (Removed in 1803)
  - Remove/Unpin all Startmenu icons
  - Remove the People and Taskview icons
  - Delete all Windows Store apps (except the Calculator, Photos, StickyNotes, and the Windows Store)
  - Install [Chocolatey](https://chocolatey.org/) and defined packages
  - Install all available [VCRedist Visual C++](https://support.microsoft.com/en-us/help/2977003/the-latest-supported-visual-c-downloads) versions (via Chocolatey)
- Advanced
  - Remove OneDrive
  - Increase wallpaper to max compression quality at no additional resource cost
  - Enable Show File Extension in File Explorer
  - Enable Show Hidden Files and Folders in File Explorer
  - Enable Remote Desktop Connection
  - Enable Wake On LAN
  - Download [MVPS](http://winhelp2002.mvps.org/hosts.txt) hosts file for system wide ad blocking
# Notes
#### Transfer all FSMO Roles
```
Move-ADDirectoryServerOperationMasterRole "DC1" –OperationMasterRole 0,1,2,3,4
```
#### Seize all FSMO Roles
```
Move-ADDirectoryServerOperationMasterRole "DC1" –OperationMasterRole 0,1,2,3,4 -Force
```
#### Reset Domain Admin Password Error 4000, 4007
```
netdom resetpwd /server:PDC.domain.com /userd:Domain\domain_admin /passwordd:*
```
#### Restore Deleted AD Object
```
Get-ADObject -Filter {displayName -eq 'Full Name'} -IncludeDeletedObjects | Restore-ADObject
```
#### Set time server to time.nist.gov
```
net stop w32time
w32tm /config /syncfromflags:manual /manualpeerlist:time.nist.gov
w32tm /config /reliable:yes
net start w32time
w32tm /query /configuration | Select-String NtpServer:
```
#### Adobe Fix
```
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" -Force
$value1 = '~ WIN7RTM'
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" -Name 'C:\Program Files (x86)\Adobe\Acrobat DC\Acrobat\AcroRd32.exe' -Value $value1
```
#### UniFi AP Downgrade
AP-AC-Pro/Lite
```
nohup mca-cli-op upgrade https://dl.ui.com/unifi/firmware/U7PG2/4.0.66.10832/BZ.qca956x.v4.0.66.10832.191023.1949.bin
```
nano-HD
```
nohup mca-cli-op upgrade https://dl.ui.com/unifi/firmware/U7NHD/4.0.66.10832/BZ.mt7621.v4.0.66.10832.191023.1949.bin
```
#### Check Uptime
```
wmic path Win32_OperatingSystem get LastBootUpTime
```
#### Windows Server ISOs
------------
| OS  | Download Link|
| ------------ | ------------ |
| Windows Server 2012 R2  | http://download.microsoft.com/download/6/2/A/62A76ABB-9990-4EFC-A4FE-C7D698DAEB96/9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9.ISO |
| Windows Server 2016  | http://download.microsoft.com/download/6/9/5/6957BB28-1FAD-4E62-B161-F873196130BD/14393.0.161119-1705.RS1_REFRESH_SERVERESSENTIALS_OEM_X64FRE_EN-US.ISO |
| Windows Server 2019 | https://software-download.microsoft.com/download/pr/17763.107.101029-1455.rs5_release_svc_refresh_SERVERESSENTIALS_OEM_X64FRE_EN-US.ISO |
#### Microsoft Office Installers
------------
| Version  | Download Link|
| ------------ | ------------ |
| Office 365 Professional Plus | http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/O365ProPlusRetail.img |
| Office 365 Business | http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/O365BusinessRetail.img |
| Office 365 Home Premium | http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/O365HomePremRetail.img |
| Office 2019 Professional Plus | https://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/ProPlus2019Retail.img |
| Office 2016 Professional Plus | https://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/ProPlusRetail.img |
| Office 2013 Professional | https://officeredir.microsoft.com/r/rlidO15C2RMediaDownload?p1=db&p2=en-US&p3=ProfessionalRetail |
| Visio 2019 Professional | https://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/VisioPro2019Retail.img |
| Project 2019 Professional | https://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/ProjectPro2019Retail.img |
| Outlook 2016 | http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/OutlookRetail.img |
