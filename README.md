# Useful scripts and notes for system administration and engineering

<details>
<summary>PowerShell</summary>

## WinMultiTool

Windows multi tool for updates, temp file cleanup, package installs

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/WinMultiTool.ps1'))
```

## ProfileMigrate

Migrates data from C:\Users\CurrentUser\Documents, Desktop, Pictures to selected path

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/ProfileMigrate.ps1'))
```

## OpenVPN_Setup

Private OpenVPN with pulled config

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/OpenVPN_Setup.ps1'))
```

## ChocoInstall

Installs [Chocolatey](https://chocolatey.org/)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/ChocoInstall.ps1'))
```

## MSOfficeInstall

Installs MS Office

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/MSOfficeInstall.ps1'))
```

## LogonStartUpTask

PowerShell logon or startup task creator

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/LogonStartUpTask.ps1'))
```

## DriverSearch

Google search with system model for drivers

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/DriverSearch.ps1'))
```

## ProductKeyFix

Remove product key and then install product key from BIOS

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/ProductKeyFix.ps1'))
```

## AutoLogin

Setup Windows Auto Login

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/AutoLogin.ps1'))
```

</details>

<details>
<summary>BIOS Keys</summary>

------------
| Manufacturer  | Key|
| ------------ | ------------ |
| Acer | Del or F2 |
| ASRock | F2 |
| Asus | Del, F10 or F9 |
| Biostar | Del |
| Dell | F2 or F12 |
| EVGA | Del |
| Gigabyte | Del |
| HP | F10 |
| Lenovo | F2, Fn + F2, F1 or Enter then F1 |
| Intel | F2 |
| MSI | Del |
| Microsoft Surface | Press and hold volume up |
| Origin PC | F2 |
| Samsung | F2 |
| Toshiba | F2 |
| Zotac | Del |

</details>
