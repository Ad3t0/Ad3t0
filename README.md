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
#### Installs all VCRedist packages, DirectX, .Net 4.8, Firefox, Google Chrome, Adobereader, 7zip
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/BasicApps.ps1'))
```
## MSOfficeInstall
#### Installs MS Office
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/MSOfficeInstall.ps1'))
```
## DriverSearch
#### Google search with system model for drivers
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/DriverSearch.ps1'))
```
## TempFilesCleanup
#### Removes all files from Windows temp directories
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/TempFilesCleanup.ps1'))
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
## SetupBeats
#### Setup ES Beats
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/SetupBeats.ps1'))
```
## GPOImport
#### GPO Import script
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/GPOImport.ps1'))
```
## ADStatusCheck
#### Checks the status of Active Directory domain health
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
## SFCDiskCheck
#### Runs sfc /scannow and disk check
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/SFCDiskCheck.ps1'))
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
## RDPWrapperInstall
#### Installs RDP Wrapper
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/RDPWrapperInstall.ps1'))
```
## CleanerWindows10
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/CleanerWindows10.ps1'))
```
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
- Remove OneDrive
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
| Visio 2016 Professional | http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/VisioProRetail.img |
| Visio 2016 Standard | http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/VisioStdRetail.img |
| Project 2019 Professional | https://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/ProjectPro2019Retail.img |
| Project 2016 Professional | http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/ProjectProRetail.img |
| Project 2016 Standard | http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/ProjectStdRetail.img |
| Outlook 2016 | http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/OutlookRetail.img |
