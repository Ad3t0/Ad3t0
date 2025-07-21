# Scripts and Notes

<link rel="shortcut icon" type="image/x-icon" href="favicon.ico">
<script src="assets/js/copy-button.js"></script>

<details open="false">
<summary markdown="span"> PowerShell Scripts</summary>

## Install-MSOffice

Installs Microsoft Office using the Office Deployment Tool with automatic architecture detection (x86/x64).

[Install-MSOffice.ps1](https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/Install-MSOffice.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/Install-MSOffice.ps1'))
```

## Move-UserProfile

Migrates user profile data (Documents, Desktop, Pictures) to a specified location for backup or migration.

[Move-UserProfile.ps1](https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/Move-UserProfile.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/Move-UserProfile.ps1'))
```

## Install-Chocolatey

Installs the Chocolatey package manager for Windows, enabling easy installation and management of software packages via command line.

[Install-Chocolatey.ps1](https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/Install-Chocolatey.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/Install-Chocolatey.ps1'))
```

## Install-AllUpdates

Installs all available Windows updates using the PSWindowsUpdate module. Supports both interactive and unattended modes (set $unattended to $true for silent installation).

[Install-AllUpdates.ps1](https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/Install-AllUpdates.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/Install-AllUpdates.ps1'))
```

## Remove-OldProfiles

Scans and removes old/unused Windows user profiles from the system with interactive confirmation for each profile, helping to free up disk space.

[Remove-OldProfiles.ps1](https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/Remove-OldProfiles.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/Remove-OldProfiles.ps1'))
```

## New-LogonStartupTask

Creates a Windows scheduled task that runs a specified PowerShell script at user logon or system startup, with options for task name and trigger type.

[New-LogonStartupTask.ps1](https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/New-LogonStartupTask.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/New-LogonStartupTask.ps1'))
```

## Enable-RDP

Enables Remote Desktop Protocol (RDP) on Windows, configures necessary firewall rules, and provides interactive prompts to add non-administrator users to the Remote Desktop Users group.

[Enable-RDP.ps1](https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/Enable-RDP.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/Enable-RDP.ps1'))
```

## Clear-Windows11Bloat

Removes Windows 11 bloatware and customizes the user interface by cleaning up the taskbar, removing unwanted startup apps, unpinning default icons, and applying a cleaner theme.

[Clear-Windows11Bloat.ps1](https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/Clear-Windows11Bloat.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/Clear-Windows11Bloat.ps1'))
```

## Enable-AutoLogin

Configures Windows automatic login for a specified user account and displays current auto-login settings stored in the registry.

[Enable-AutoLogin.ps1](https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/Enable-AutoLogin.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/Enable-AutoLogin.ps1'))
```

## Install-ZabbixAgent

Downloads, installs, and configures the Zabbix monitoring agent for Windows with PSK (Pre-Shared Key) authentication, including firewall rules and service configuration.

[Install-ZabbixAgent.ps1](https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/Install-ZabbixAgent.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/Install-ZabbixAgent.ps1'))
```

## New-LocalUser

Creates a new local Windows user account with options to auto-generate a secure password or set one manually. Includes interactive prompts to add the user to Administrators and/or Remote Desktop Users groups.

[New-LocalUser.ps1](https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/New-LocalUser.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/New-LocalUser.ps1'))
```

## Set-DailyRestartTask

Creates a scheduled task to restart the computer daily at a specified time with a 30-second warning.

[Set-DailyRestartTask.ps1](https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/Set-DailyRestartTask.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/Set-DailyRestartTask.ps1'))
```

</details>

<details open="false">
<summary markdown="span"> Bash Scripts</summary>

Initializes an Ubuntu server template with common packages, system configurations, and security hardening.

```bash
sudo bash -c "$(wget -qLO - https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/bash/serverTemplateSetup.sh)"
```

Installs Zabbix Agent 2 with PSK auth, Proxmox SMART, and ZFS monitoring support.

```bash
sudo bash -c "$(wget -qLO - https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/bash/zabbixAgentSetup.sh)"
```

Expands LVM partitions to utilize all available disk space on Ubuntu.

```bash
sudo bash -c "$(wget -qLO - https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/bash/autoExpandLVM.sh)"
```

Installs and enables the QEMU Guest Agent for improved Proxmox guest interaction.

```bash
sudo bash -c "$(wget -qLO - https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/bash/qemuAgentSetup.sh)"
```

Installs Docker and Docker Compose.

```bash
sudo bash -c "$(wget -qLO - https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/bash/installDocker.sh)"
```

Automates secure SSH configuration: key generation, permissions, `authorized_keys`, and sshd_config hardening.

```bash
sudo bash -c "$(wget -qLO - https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/bash/SshAuthConfigurator.sh)"
```

</details>

<details>
<summary markdown="span"> Windows Notes</summary>

### Convert Windows Server 2019 Evaluation to Standard

```powershell
DISM /online /Set-Edition:ServerStandard /ProductKey:N69G4-B89J2-4G8F4-WWYCC-J464C /AcceptEula
```

### Convert Windows Server 2019 Evaluation to Datacenter

```powershell
DISM /online /Set-Edition:ServerDatacenter /ProductKey:WMDGN-G9PQG-XVVXX-R3X43-63DFG /AcceptEula
```

### Convert Windows Server 2022 Evaluation to Datacenter

```powershell
DISM /online /Set-Edition:ServerDatacenter /ProductKey:WX4NM-KYWYW-QJJR4-XV3QB-6VM33 /AcceptEula
```

### Transfer all FSMO Roles

```powershell
Move-ADDirectoryServerOperationMasterRole "DC1" -OperationMasterRole 0,1,2,3,4
```

### Seize all FSMO Roles

```powershell
Move-ADDirectoryServerOperationMasterRole "DC1" -OperationMasterRole 0,1,2,3,4 -Force
```

### Reset Domain Admin Password Error 4000, 4007

```powershell
netdom resetpwd /server:PDC.domain.com /userd:Domain\domain_admin /passwordd:*
```

### Restore Deleted AD Object

```powershell
Get-ADObject -Filter {displayName -eq 'Full Name'} -IncludeDeletedObjects | Restore-ADObject
```

### Set time server to domain hierarchy

```powershell
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\w32time\TimeProviders\VMICTimeProvider" -Name "Enabled" -Value 0
w32tm /query /source
w32tm /config /syncfromflags:DOMHIER /update
w32tm /resync
```

### Set time server

```powershell
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\w32time\TimeProviders\VMICTimeProvider" -Name "Enabled" -Value 0
w32tm /config /manualpeerlist:time.nist.gov,0x1 /syncfromflags:manual /reliable:yes /update
net stop w32time
net start w32time
w32tm /resync /force
w32tm /query /configuration
```

### Generate and export .pfx cert

```powershell
$notafter = (Get-date).AddYears(10)
$cert = New-SelfSignedCertificate -certstorelocation cert:\localmachine\my -dnsname test.com -NotAfter $notafter
$pwd = ConvertTo-SecureString -String '12345678' -Force -AsPlainText
$path = 'cert:\localMachine\my\' + $cert.thumbprint
Export-PfxCertificate -cert $path -FilePath c:\cert.pfx -Password $pwd
```

</details>

<details>
<summary markdown="span"> Ubuntu/Debian Notes</summary>

Set Timezone

```bash
sudo timedatectl set-timezone America/Denver
```

Edit Crontab

```bash
sudo crontab -e
sudo service cron reload
```

Sysbench Benchmark

```bash
#Install if needed
apt install sysbench
#Run Benchmarks
sysbench cpu run
sysbench memory run
sysbench fileio --file-test-mode=seqwr run
sysbench fileio cleanup
```

Expand Disk Size

```bash
df -h
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
```

Montor network interface bandwidth

```bash
tcptrack -i eno1
```

Disk Speed Test

```bash
hdparm -Tt /dev/sda
```

</details>

<details>
<summary markdown="span"> Proxmox Notes</summary>

Awesome Proxmox Community Scripts (Proxmox Helper Scripts VE 7 Post Install [https://community-scripts.github.io/ProxmoxVE/scripts](https://community-scripts.github.io/ProxmoxVE/scripts)

Change IP in

```bash
nano /etc/network/interfaces
nano /etc/hosts
```

Remove Node From Cluster

```bash
#Set to new number of nodes
pvecm expected 1
#Remove node2
pvecm delnode node2
```

ZFS Set Volsize

```bash
zfs set volsize=120G rpool/data/vm-<VM ID>-disk-<DISK ID>
```

Set dedicated network interface for replication

```bash
echo "migration: insecure,network=172.17.93.0/24" >> /etc/pve/datacenter.cfg
```

Manually Remove Snapshot

```bash
nano /etc/pve/qemu-server/<vmid>.conf
zfs list
zfs destroy
```

</details>
