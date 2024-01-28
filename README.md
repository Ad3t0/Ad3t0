# Scripts and Notes

<link rel="shortcut icon" type="image/x-icon" href="favicon.ico">

<details open="false">
<summary markdown="span"> PowerShell Scripts</summary>

## MSOfficeInstall

Installs MS Office

[MSOfficeInstall.ps1](https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/MSOfficeInstall.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/MSOfficeInstall.ps1'))
```

## ProfileMigrate

Copies data from C:\Users\CurrentUser\Documents, Desktop, Pictures to selected path

[ProfileMigrate.ps1](https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/ProfileMigrate.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/ProfileMigrate.ps1'))
```

## ChocoInstall

Installs [https://chocolatey.org/](https://chocolatey.org/)

[ChocoInstall.ps1](https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/ChocoInstall.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/ChocoInstall.ps1'))
```

## LogonStartUpTask

PowerShell logon or startup task creator

[LogonStartUpTask.ps1](https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/LogonStartUpTask.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/LogonStartUpTask.ps1'))
```

## DriverSearch

Google search with system model for drivers in default browser

[DriverSearch.ps1](https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/DriverSearch.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/DriverSearch.ps1'))
```

## AutoLogin

Setup Windows auto login and display current

[AutoLogin.ps1](https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/AutoLogin.ps1)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Ad3t0/windows/master/powershell-core/AutoLogin.ps1'))
```

</details>

<details>
<summary markdown="span"> Bash Scripts</summary>

Script for Setting up Netplan

```bash
curl -sSL https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/bash/netplanSetup.sh | bash
```

Script for Setting up SSH PubKeyAuth and Root Login

```bash
curl -sSL https://raw.githubusercontent.com/Ad3t0/Ad3t0/master/bash/copysshid.sh | bash
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

Ubuntu 22.04 Zabbix Agent Install

```bash
sudo apt update
sudo apt upgrade -y
wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu22.04_all.deb
sudo dpkg -i zabbix-release_6.0-4+ubuntu22.04_all.deb
sudo apt update
sudo apt install zabbix-agent2 -y
sudo sed -i 's/Server=127.0.0.1/Server=0.0.0.0\/0/' /etc/zabbix/zabbix_agent2.conf
sudo systemctl enable zabbix-agent2
sudo systemctl restart zabbix-agent2
```

Ubuntu 20.04 Zabbix Agent Install

```bash
sudo apt update
sudo apt upgrade -y
wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu20.04_all.deb
sudo dpkg -i zabbix-release_6.0-4+ubuntu20.04_all.deb
sudo apt update
sudo apt install zabbix-agent2 -y
sudo sed -i 's/Server=127.0.0.1/Server=0.0.0.0\/0/' /etc/zabbix/zabbix_agent2.conf
sudo systemctl enable zabbix-agent2
sudo systemctl restart zabbix-agent2
```

Montor network interface bandwidth

```bash
tcptrack -i eno1
```

Install QEMU Guest Agent

```bash
sudo apt install qemu-guest-agent
sudo systemctl start qemu-guest-agent
```

Set Network Config

```bash
sudo nano /etc/netplan/01-netcfg.yaml
```

```bash
network:
  version: 2
  renderer: networkd
  ethernets:
    ens160:
      dhcp4: 'no'
      addresses:
        - 192.168.250.10/24
      gateway4: 192.168.250.1
      nameservers:
        search:
          - TEST.lan
        addresses:
          - 192.168.250.2
          - 192.168.250.1
```

```bash
sudo netplan apply
```

Disk Speed Test

```bash
hdparm -Tt /dev/sda
```

</details>

<details>
<summary markdown="span"> MacOS Notes</summary>

#### Mac Setup

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/admin/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
sudo softwareupdate --install-rosetta
brew install --cask google-chrome ringcentral appcleaner adobe-acrobat-reader adobe-creative-cloud microsoft-office
sudo dscl . create /Users/admin IsHidden 1
```

</details>

<details>
<summary markdown="span"> Proxmox Notes</summary>

Proxmox Helper Scripts VE 7 Post Install [https://tteck.github.io/Proxmox/](https://tteck.github.io/Proxmox/)

```bash
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/post-pve-install.sh)"
```

Proxmox Script VE 8 Upgrade [https://tteck.github.io/Proxmox/](https://tteck.github.io/Proxmox/)

```bash
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/pve8-upgrade.sh)"
```

Change IP in

```bash
nano /etc/network/interfaces
nano /etc/hosts
```

Proxmox Dark Theme [https://tteck.github.io/Proxmox/](https://tteck.github.io/Proxmox/)

```bash
bash <(curl -s https://raw.githubusercontent.com/Weilbyte/PVEDiscordDark/master/PVEDiscordDark.sh ) install
```

Remove Node From Cluster

```bash
#Set to new number of nodes
pvecm expected 1
#Remove node2
pvecm delnode node2
```

Zabbix Setup

```bash
wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu20.04_all.deb
dpkg -i zabbix-release_6.4-1+ubuntu20.04_all.deb
apt update
apt install zabbix-agent2 zabbix-agent2-plugin-*
sed -i 's/Server=127.0.0.1/Server=192.168.250.10/' /etc/zabbix/zabbix_agent2.conf
systemctl restart zabbix-agent2
systemctl enable zabbix-agent2
```

ZFS Set Volsize

```bash
zfs set volsize=120G rpool/data/vm-<VM ID>-disk-<DISK ID>
```

Install QEMU Guest Agent

```bash
sudo apt install qemu-guest-agent
sudo systemctl start qemu-guest-agent
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

<details>
<summary markdown="span"> Microsoft Download Links</summary>

### Windows Server ISOs

<table>
   <tbody>
      <tr>
         <td>OS</td>
         <td>Download Link</td>
      </tr>
      <tr>
         <td>Windows Server 2012 R2</td>
         <td><a href="http://download.microsoft.com/download/6/2/A/62A76ABB-9990-4EFC-A4FE-C7D698DAEB96/9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9.ISO">http://download.microsoft.com/download/6/2/A/62A76ABB-9990-4EFC-A4FE-C7D698DAEB96/9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9.ISO</a></td>
      </tr>
      <tr>
         <td>Windows Server 2016</td>
         <td><a href="http://download.microsoft.com/download/6/9/5/6957BB28-1FAD-4E62-B161-F873196130BD/14393.0.161119-1705.RS1_REFRESH_SERVERESSENTIALS_OEM_X64FRE_EN-US.ISO">http://download.microsoft.com/download/6/9/5/6957BB28-1FAD-4E62-B161-F873196130BD/14393.0.161119-1705.RS1_REFRESH_SERVERESSENTIALS_OEM_X64FRE_EN-US.ISO</a></td>
      </tr>
      <tr>
         <td>Windows Server 2019</td>
         <td><a href="https://software-download.microsoft.com/download/pr/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso">https://software-download.microsoft.com/download/pr/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso</a></td>
      </tr>
      <tr>
         <td>Windows Server 2022</td>
         <td><a title="https://software-download.microsoft.com/download/sg/20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso" href="https://software-download.microsoft.com/download/sg/20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso">https://software-download.microsoft.com/download/sg/20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso</a></td>
      </tr>
   </tbody>
</table>

### Microsoft Office Installers

<table>
   <tbody>
      <tr>
         <td>Version</td>
         <td>Download Link</td>
      </tr>
      <tr>
         <td>Office 365 Professional Plus</td>
         <td><a href="http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/O365ProPlusRetail.img">http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/O365ProPlusRetail.img</a></td>
      </tr>
      <tr>
         <td>Office 365 Business</td>
         <td><a href="http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/O365BusinessRetail.img">http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/O365BusinessRetail.img</a></td>
      </tr>
      <tr>
         <td>Office 365 Home Premium</td>
         <td><a href="http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/O365HomePremRetail.img">http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/O365HomePremRetail.img</a></td>
      </tr>
      <tr>
         <td>Office 2019 Professional Plus</td>
         <td><a href="https://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/ProPlus2019Retail.img">https://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/ProPlus2019Retail.img</a></td>
      </tr>
      <tr>
         <td>Office 2016 Professional Plus</td>
         <td><a href="https://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/ProPlusRetail.img">https://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/ProPlusRetail.img</a></td>
      </tr>
      <tr>
         <td>Office 2013 Professional</td>
         <td><a href="https://officeredir.microsoft.com/r/rlidO15C2RMediaDownload?p1=db&amp;p2=en-US&amp;p3=ProfessionalRetail">https://officeredir.microsoft.com/r/rlidO15C2RMediaDownload?p1=db&amp;p2=en-US&amp;p3=ProfessionalRetail</a></td>
      </tr>
      <tr>
         <td>Visio 2019 Professional</td>
         <td><a href="https://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/VisioPro2019Retail.img">https://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/VisioPro2019Retail.img</a></td>
      </tr>
      <tr>
         <td>Visio 2016 Professional</td>
         <td><a href="http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/VisioProRetail.img">http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/VisioProRetail.img</a></td>
      </tr>
      <tr>
         <td>Visio 2016 Standard</td>
         <td><a href="http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/VisioStdRetail.img">http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/VisioStdRetail.img</a></td>
      </tr>
      <tr>
         <td>Project 2019 Professional</td>
         <td><a href="https://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/ProjectPro2019Retail.img">https://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/ProjectPro2019Retail.img</a></td>
      </tr>
      <tr>
         <td>Project 2016 Professional</td>
         <td><a href="http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/ProjectProRetail.img">http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/ProjectProRetail.img</a></td>
      </tr>
      <tr>
         <td>Project 2016 Standard</td>
         <td><a href="http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/ProjectStdRetail.img">http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/ProjectStdRetail.img</a></td>
      </tr>
      <tr>
         <td>Outlook 2016</td>
         <td><a href="http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/OutlookRetail.img">http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/OutlookRetail.img</a></td>
      </tr>
   </tbody>
</table>

</details>

<details>
<summary markdown="span"> BIOS Keys</summary>

<table>
   <tr>
      <td>Manufacturer</td>
      <td>Key</td>
   </tr>
   <tr>
      <td>Acer</td>
      <td>Del or F2</td>
   </tr>
   <tr>
      <td>ASRock</td>
      <td>F2</td>
   </tr>
   <tr>
      <td>Asus</td>
      <td>Del, F10 or F9</td>
   </tr>
   <tr>
      <td>Biostar</td>
      <td>Del</td>
   </tr>
   <tr>
      <td>Dell</td>
      <td>F2 or F12</td>
   </tr>
   <tr>
      <td>EVGA</td>
      <td>Del</td>
   </tr>
   <tr>
      <td>Gigabyte</td>
      <td>Del</td>
   </tr>
   <tr>
      <td>HP</td>
      <td>F10</td>
   </tr>
   <tr>
      <td>Lenovo</td>
      <td>F2, Fn + F2, F1 or Enter then F1</td>
   </tr>
   <tr>
      <td>Intel</td>
      <td>F2</td>
   </tr>
   <tr>
      <td>MSI</td>
      <td>Del</td>
   </tr>
   <tr>
      <td>Microsoft Surface</td>
      <td>Press and hold volume up</td>
   </tr>
   <tr>
      <td>Origin PC</td>
      <td>F2</td>
   </tr>
   <tr>
      <td>Samsung</td>
      <td>F2</td>
   </tr>
   <tr>
      <td>Toshiba</td>
      <td>F2</td>
   </tr>
   <tr>
      <td>Zotac</td>
      <td>Del</td>
   </tr>
</table>

</details>

<details>
<summary markdown="span"> IP BlackLists</summary>

<table>
   <tbody>
      <tr>
         <td>Category</td>
         <td>Name</td>
         <td>Description</td>
         <td>Source</td>
         <td>Header/Label</td>
      </tr>
      <tr>
         <td>Anonymizers</td>
         <td>dan.me.uk</td>
         <td>This list contains a full list of all TOR nodes</td>
         <td><a href="https://www.dan.me.uk/torlist/ ">https://www.dan.me.uk/torlist/</a></td>
         <td>Anon_TOR</td>
      </tr>
      <tr>
         <td>Anonymizers</td>
         <td>MaxMind</td>
         <td>MaxMind.com sample list of high-risk IP addresses.</td>
         <td><a href="https://www.maxmind.com/en/high-risk-ip-sample-list">https://www.maxmind.com/en/high-risk-ip-sample-list</a></td>
         <td>Anon_MaxMind</td>
      </tr>
      <tr>
         <td>Attacks</td>
         <td>Talos</td>
         <td>TalosIntel.com List of known malicious network threats</td>
         <td><a href="http://talosintel.com/feeds/ip-filter.blf">http://talosintel.com/feeds/ip-filter.blf</a></td>
         <td>Talos</td>
      </tr>
      <tr>
         <td>Attacks</td>
         <td>BadIPs 15d</td>
         <td>Bad IPs in category any with score above 2 and age less than 15d</td>
         <td><a href="https://www.badips.com/get/list/any/2?age=15d">https://www.badips.com/get/list/any/2?age=15d</a></td>
         <td>BadIPs_15d</td>
      </tr>
      <tr>
         <td>Attacks</td>
         <td>BadIPs 30d</td>
         <td>BadIPs.com Bad IPs in category any with score above 2 and age less than 30d</td>
         <td><a href="https://www.badips.com/get/list/any/2?age=30d">https://www.badips.com/get/list/any/2?age=30d</a></td>
         <td>BadIPs_30d</td>
      </tr>
      <tr>
         <td>Attacks</td>
         <td>Blocklist.de</td>
         <td>Blocklist.de IPs that have been detected by fail2ban in the last 48 hours</td>
         <td><a href="http://lists.blocklist.de/lists/all.txt">http://lists.blocklist.de/lists/all.txt</a></td>
         <td>Blocklist.de</td>
      </tr>
      <tr>
         <td>Attacks</td>
         <td>Cyber Crime WHQ</td>
         <td>Block IPs</td>
         <td><a href="https://cybercrime-tracker.net/fuckerz.php">https://cybercrime-tracker.net/fuckerz.php</a></td>
         <td>Cyber_Crime</td>
      </tr>
      <tr>
         <td>Attacks</td>
         <td>ISC_1d</td>
         <td>https://isc.sans.edu/api/sources/attacks/1000/1?text</td>
         <td><a href="https://cinsarmy.com/list/ci-badguys.txt">https://cinsarmy.com/list/ci-badguys.txt</a></td>
         <td>&nbsp;</td>
      </tr>
      <tr>
         <td>Attacks</td>
         <td>Emerging Threats and DShield - Block IPs</td>
         <td>This is combines several lists. At the moment of writing the blocklist contains the following:</td>
         <td>&nbsp;</td>
         <td>&nbsp;</td>
      </tr>
      <tr>
         <td>Attacks</td>
         <td>Emerging Threats and DShield - Compromised IPs</td>
         <td>Compromised IPs</td>
         <td><a href="https://rules.emergingthreats.net/blockrules/compromised-ips.txt">https://rules.emergingthreats.net/blockrules/compromised-ips.txt</a></td>
         <td>ET_Comp_IP</td>
      </tr>
      <tr>
         <td>Attacks</td>
         <td>GreenSnow</td>
         <td>GreenSnow.co the blacklisted list of IPs for online servers.</td>
         <td><a href="https://blocklist.greensnow.co/greensnow.txt">https://blocklist.greensnow.co/greensnow.txt</a></td>
         <td>GreenSnow</td>
      </tr>
      <tr>
         <td>Attacks</td>
         <td>MyIP.ms</td>
         <td>Our sites are visited by tens of thousands of people every day. Our unique protection system allows us to easily identify the IP of Unknown Spam Bots / Crawlers and other IP with dangerous software. Below are published in real time our blacklist of such IP's. Hope it will be helpful for you. Read More</td>
         <td><a href="https://www.myip.ms/files/blacklist/general/latest_blacklist.txt">https://www.myip.ms/files/blacklist/general/latest_blacklist.txt</a></td>
         <td>MyIP_ms</td>
      </tr>
      <tr>
         <td>Attacks</td>
         <td>Internet Storm Center</td>
         <td>IP Block List</td>
         <td><a href="https://isc.sans.edu/api/sources/attacks/1000/30?text">https://isc.sans.edu/api/sources/attacks/1000/30?text</a></td>
         <td>ISC_30d</td>
      </tr>
      <tr>
         <td>Attacks</td>
         <td>NormShield</td>
         <td>NormShield.com IPs in category attack with severity all</td>
         <td><a href="https://iplists.firehol.org/files/normshield_all_attack.ipset">https://iplists.firehol.org/files/normshield_all_attack.ipset</a></td>
         <td>NormShield_All</td>
      </tr>
      <tr>
         <td>Attacks</td>
         <td>Snort IPfilter</td>
         <td>Same as TALOS</td>
         <td><a href="http://labs.snort.org/feeds/ip-filter.blf">http://labs.snort.org/feeds/ip-filter.blf</a></td>
         <td>SnortIPfilter</td>
      </tr>
      <tr>
         <td>Malware</td>
         <td>Abuse.ch Feodo</td>
         <td>Included in RW. Abuse.ch Feodo tracker trojan includes IPs which are being used by Feodo (also known as Cridex or Bugat) which commits ebanking fraud</td>
         <td><a href="https://feodotracker.abuse.ch/blocklist/?download=ipblocklist">https://feodotracker.abuse.ch/blocklist/?download=ipblocklist</a></td>
         <td>Abusech_Feodo</td>
      </tr>
      <tr>
         <td>Malware</td>
         <td>Abuse.ch Ransomware Tracker Feed</td>
         <td>Abuse.ch Ransomware Tracker Ransomware Tracker tracks and monitors the status of domain names, IP addresses and URLs that are associated with Ransomware, such as Botnet C&amp;C servers, distribution sites and payment sites.</td>
         <td><a href="https://ransomwaretracker.abuse.ch/feeds/csv/">https://ransomwaretracker.abuse.ch/feeds/csv/</a></td>
         <td>Abusech_Feed</td>
      </tr>
      <tr>
         <td>Malware</td>
         <td>Abuse.ch Ransomware Tracker RW</td>
         <td>Abuse.ch Ransomware Tracker Ransomware Tracker tracks and monitors the status of domain names, IP addresses and URLs that are associated with Ransomware, such as Botnet C&amp;C servers, distribution sites and payment sites.</td>
         <td><a href="https://ransomwaretracker.abuse.ch/downloads/RW_IPBL.txt">https://ransomwaretracker.abuse.ch/downloads/RW_IPBL.txt</a></td>
         <td>Abusech_RW</td>
      </tr>
      <tr>
         <td>Malware</td>
         <td>Abuse.ch SSL Blacklist Agressive</td>
         <td>Abuse.ch SSL Blacklist The aggressive version of the SSL IP Blacklist contains all IPs that SSLBL ever detected being associated with a malicious SSL certificate</td>
         <td><a href="https://sslbl.abuse.ch/blacklist/sslipblacklist_aggressive.csv">https://sslbl.abuse.ch/blacklist/sslipblacklist_aggressive.csv</a></td>
         <td>Abusech_sslbl</td>
      </tr>
      <tr>
         <td>Malware</td>
         <td>Abuse.ch Zeus</td>
         <td>Included in RW. Abuse.ch Zeus tracker standard, contains the same data as the ZeuS IP blocklist (zeus_badips) but with the slight difference that it doesn't exclude hijacked websites (level 2) and free web hosting providers (level 3)</td>
         <td><a href="https://zeustracker.abuse.ch/blocklist.php?download=ipblocklist">https://zeustracker.abuse.ch/blocklist.php?download=ipblocklist</a></td>
         <td>Abusech_Zeus</td>
      </tr>
      <tr>
         <td>Malware</td>
         <td>Bambenek</td>
         <td>Master Feed of known, active and non-sinkholed C&amp;Cs IP addresses</td>
         <td><a href="https://osint.bambenekconsulting.com/feeds/c2-ipmasterlist.txt">https://osint.bambenekconsulting.com/feeds/c2-ipmasterlist.txt</a></td>
         <td>Bambenek_All</td>
      </tr>
      <tr>
         <td>Malware</td>
         <td>IBM X-Force</td>
         <td>IBM X-Force Exchange Botnet Command and Control Servers</td>
         <td><a href="https://iplists.firehol.org/files/xforce_bccs.ipset">https://iplists.firehol.org/files/xforce_bccs.ipset</a></td>
         <td>IBM_XForce</td>
      </tr>
      <tr>
         <td>Malware</td>
         <td>Malc0de</td>
         <td>Malc0de.com malicious IPs of the last 30 days</td>
         <td><a href="http://malc0de.com/bl/IP_Blacklist.txt">http://malc0de.com/bl/IP_Blacklist.txt</a></td>
         <td>Malc0de</td>
      </tr>
      <tr>
         <td>Malware</td>
         <td>MalwareDomainList</td>
         <td>malwaredomainlist.com list of malware active ip addresses</td>
         <td><a href="http://www.malwaredomainlist.com/hostslist/ip.txt">http://www.malwaredomainlist.com/hostslist/ip.txt</a></td>
         <td>MalwareDomainList</td>
      </tr>
      <tr>
         <td>Malware</td>
         <td>URLVir</td>
         <td>URLVir.com Active Malicious IP Addresses Hosting Malware. URLVir is an online security service developed by NoVirusThanks Company Srl that automatically monitors changes of malicious URLs (executable files)</td>
         <td><a href="http://www.urlvir.com/export-ip-addresses/">http://www.urlvir.com/export-ip-addresses/</a></td>
         <td>URLVir</td>
      </tr>
      <tr>
         <td>Malware</td>
         <td>VxVault</td>
         <td>VxVault The latest 100 additions of VxVault.</td>
         <td><a href="http://vxvault.net/ViriList.php?s=0&amp;m=100">http://vxvault.net/ViriList.php?s=0&amp;m=100</a></td>
         <td>VxVault</td>
      </tr>
      <tr>
         <td>Reputation</td>
         <td>AlienVault</td>
         <td>AlienVault.com IP reputation database</td>
         <td><a href="https://reputation.alienvault.com/reputation.generic">https://reputation.alienvault.com/reputation.generic</a></td>
         <td>AlienVault</td>
      </tr>
      <tr>
         <td>Reputation</td>
         <td>Binary Defense</td>
         <td>Binary Defense Systems Artillery Threat Intelligence Feed and Banlist Feed</td>
         <td><a href="https://www.binarydefense.com/banlist.txt">https://www.binarydefense.com/banlist.txt</a></td>
         <td>BinaryDefense</td>
      </tr>
      <tr>
         <td>Reputation</td>
         <td>CINS Army</td>
         <td>CIArmy.com IPs with poor Rogue Packet score that have not yet been identified as malicious by the community</td>
         <td><a href="http://cinsscore.com/list/ci-badguys.txt">http://cinsscore.com/list/ci-badguys.txt</a></td>
         <td>CINS_Army</td>
      </tr>
      <tr>
         <td>Attacks</td>
         <td>ISCBlock</td>
         <td>&nbsp;</td>
         <td><a href="https://isc.sans.edu/feeds/block.txt">https://isc.sans.edu/feeds/block.txt</a></td>
         <td>&nbsp;</td>
      </tr>
      <tr>
         <td>Anonymizers</td>
         <td>ProxyLists_1d</td>
         <td>&nbsp;</td>
         <td><a href="https://iplists.firehol.org/files/proxylists_1d.ipset">https://iplists.firehol.org/files/proxylists_1d.ipset</a></td>
         <td>&nbsp;</td>
      </tr>
      <tr>
         <td>Malware</td>
         <td>Abuse_DYRE</td>
         <td>&nbsp;</td>
         <td><a href="https://sslbl.abuse.ch/blacklist/dyre_sslipblacklist.csv">https://sslbl.abuse.ch/blacklist/dyre_sslipblacklist.csv</a></td>
         <td>&nbsp;</td>
      </tr>
   </tbody>
</table>

</details>
