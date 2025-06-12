# Scripts and Notes

<link rel="shortcut icon" type="image/x-icon" href="favicon.ico">
<script src="assets/js/copy-button.js"></script>

<details open="false">
<summary markdown="span"> PowerShell Scripts</summary>

## MSOfficeInstall

Installs MS Office

[MSOfficeInstall.ps1](https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/MSOfficeInstall.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/MSOfficeInstall.ps1'))
```

## ProfileMigrate

Copies data from C:\Users\CurrentUser\Documents, Desktop, Pictures to selected path

[ProfileMigrate.ps1](https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/ProfileMigrate.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/ProfileMigrate.ps1'))
```

## ChocoInstall

Installs [https://chocolatey.org/](https://chocolatey.org/)

[ChocoInstall.ps1](https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/ChocoInstall.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/ChocoInstall.ps1'))
```

## InstallAllUpdates

Installs all Windows updates without confirmation

[InstallAllUpdates.ps1](https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/InstallAllUpdates.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/InstallAllUpdates.ps1'))
```

## RemoveOldProfiles

Remove old user profiles with prompts and confirmations

[RemoveOldProfiles.ps1](https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/RemoveOldProfiles.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/RemoveOldProfiles.ps1'))
```

## LogonStartUpTask

PowerShell logon or startup task creator

[LogonStartUpTask.ps1](https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/LogonStartUpTask.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/LogonStartUpTask.ps1'))
```

## DriverSearch

Google search with system model for drivers in default browser

[DriverSearch.ps1](https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/DriverSearch.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/DriverSearch.ps1'))
```

## AutoLogin

Setup Windows auto login and display current

[AutoLogin.ps1](https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/AutoLogin.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/AutoLogin.ps1'))
```

## ZabbixAgentSetup

Setup Windows Zabbix agent with PSK auth

[ZabbixAgentSetup.ps1](https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/ZabbixAgentSetup.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/powershell/ZabbixAgentSetup.ps1'))
```

</details>

<details open="false">
<summary markdown="span"> Bash Scripts</summary>

Ubuntu template setup script

```bash
sudo bash -c "$(wget -qLO - https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/bash/serverTemplateSetup.sh)"
```

Zabbix Agent 2 setup script (supports PSK auth, Proxmox SMART monitoring, and ZFS monitoring)

```bash
sudo bash -c "$(wget -qLO - https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/bash/zabbixAgentSetup.sh)"
```

Automatically expands disk and LVM partitions to utilize all available space on Ubuntu systems

```bash
sudo bash -c "$(wget -qLO - https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/bash/autoExpandLVM.sh)"
```

QEMU Guest Agent setup script

```bash
sudo bash -c "$(wget -qLO - https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/bash/qemuAgentSetup.sh)"
```

Docker install script

```bash
sudo bash -c "$(wget -qLO - https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/bash/installDocker.sh)"
```

Automates SSH key generation, sets permissions, updates authorized_keys, and configures SSH daemon securely

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
