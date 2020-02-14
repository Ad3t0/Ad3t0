# Windows 7, 8, 10 and Windows Server PowerShell Scripts
[![](https://i.imgur.com/bzG7kdD.png)](#)

[OpenVPN](#openvpn)  
[OpenVPN_InstallOnly](#openvpn_installonly)  
[ChocoInstall](#chocoinstall)  
[DriverSearch](#driversearch)  
[PFMG](#pfmg)  
[PSS3B](#pss3b)  
[AutoIPK](#autoipk)  
[WINC](#winc)  
[DG](#dg)  
[WinSatFormal](#winsatformal)  
[GCloudADA](#gcloudada)  
[CredShow](#credshow)  
[GPOImport](#gpoimport)  
[ADBatchAdd](#adbatchadd)  
[MSRAQuickConnect](#msraquickconnect)  
[WINRMgpupdate](#winrmgpupdate)  
[WINRMScript](#winrmscript)  
[WiFiQR](#wifiqr)  
[CleanerWindows10](#cleanerwindows10)  
[Notes](#notes)  
[Windows Server ISOs](#windows-server-isos)  
### **Paste links into PowerShell**
## OpenVPN
#### Private OpenVPN with pulled config
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/OpenVPN.ps1'))
```
## OpenVPN_InstallOnly
#### Private OpenVPN with pulled config
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/OpenVPN_InstallOnly.ps1'))
```
## ChocoInstall
#### Installs [Chocolatey](https://chocolatey.org/)
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/ChocoInstall.ps1'))
```
## DriverSearch
#### Google search with system model for drivers
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/DriverSearch.ps1'))
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
## AutoIPK
#### Download product key list and attempt to license
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/AutoIPK.ps1'))
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
## GCloudADA
#### GCloud setup
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/GCloudADA.ps1'))
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
## ADBatchAdd
#### Batch add Active Directory users into a new Organizational Unit named Employees and create private home directories from a text file formatted like
```
John Snow
Elon Musk
Jason Bourne
```
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/ADBatchAdd.ps1'))
```
## MSRAQuickConnect
#### Microsoft Remote Assistant Quick Connect
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/MSRAQuickConnect.ps1'))
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
#### Set time server to time.nist.gov
```
net stop w32time
w32tm /config /syncfromflags:manual /manualpeerlist:time.nist.gov
w32tm /config /reliable:yes
net start w32time
w32tm /query /configuration | Select-String NtpServer:
```
#### Windows Server ISOs
------------
| OS  | Download Link|
| ------------ | ------------ |
| Windows Server 2012 R2  | http://download.microsoft.com/download/6/2/A/62A76ABB-9990-4EFC-A4FE-C7D698DAEB96/9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9.ISO |
| Windows Server 2016  | http://download.microsoft.com/download/6/9/5/6957BB28-1FAD-4E62-B161-F873196130BD/14393.0.161119-1705.RS1_REFRESH_SERVERESSENTIALS_OEM_X64FRE_EN-US.ISO |
| Windows Server 2019 | https://software-download.microsoft.com/download/pr/17763.107.101029-1455.rs5_release_svc_refresh_SERVERESSENTIALS_OEM_X64FRE_EN-US.ISO |
