# Windows 7, 8, 10 and Windows Server PowerShell Scripts
[![](https://i.imgur.com/bzG7kdD.png)](#)

[OpenVPN](#openvpn)  
[ChocoInstall](#chocoinstall)  
[DriverSearch](#driversearch)  
[AutoIPK](#autoipk)  
[BelarcAudit](#belarcaudit)  
[ADBatchAdd](#adbatchadd)  
[MSRAQuickConnect](#msraquickconnect)  
[WINRMgpupdate](#winrmgpupdate)  
[WINRMScript](#winrmscript)  
[ProfileMigrate](#profilemigrate)  
[WindowsServerGlacierBackup](#windowsserverglacierbackup)  
[WiFiQR](#wifiqr) 
[CleanerWindows10](#cleanerwindows10) 
[Notes](#notes)  
[Server Files](#server-files)  
### **Paste links into PowerShell**
## OpenVPN
#### Private OpenVPN with pulled config
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/OpenVPN.ps1'))
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
## AutoIPK
#### Download product key list and attempt to license
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/AutoIPK.ps1'))
```
## BelarcAudit
#### Run a Windows PC Audit using BelarcAdvisor
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/BelarcAudit.ps1'))
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
## ProfileMigrate
#### Profile migration tool
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/ProfileMigrate.ps1'))
```
## WindowsServerGlacierBackup
#### Creates a Windows Server Manual Backup
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/WindowsServerGlacierBackup.ps1'))
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
#### Force taskill example
```
taskkill /IM firefox.exe /F
```
#### Set time server to time.nist.gov
```
net stop w32time
w32tm /config /syncfromflags:manual /manualpeerlist:time.nist.gov
w32tm /config /reliable:yes
net start w32time
w32tm /query /configuration | Select-String NtpServer:
```
#### VS Code Notes
```
Auto Format: Shift + Alt + F
Command Palette: Ctrl + Shift + P
```
#### Shared Software
https://mega.nz/#F!ZaRSwCDS!P43lje-ebk6JW_TB2Mhyvw
#### Server Files
https://mega.nz/#F!MLoQkSiC!963pGQ2axa63DW-1Lv4UQA
