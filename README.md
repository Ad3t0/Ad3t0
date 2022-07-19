# Scripts and Notes for System Administration and Engineering

<details>
<summary markdown="span"> PowerShell Scripts</summary>

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
<summary markdown="span"> Bash Scripts</summary>

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
Move-ADDirectoryServerOperationMasterRole "DC1" –OperationMasterRole 0,1,2,3,4
```

### Seize all FSMO Roles

```powershell
Move-ADDirectoryServerOperationMasterRole "DC1" –OperationMasterRole 0,1,2,3,4 -Force
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

</details>

<details>
<summary markdown="span"> Microsoft Download Links</summary>

#### Windows Server ISOs

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

#### Microsoft Office Installers

------------
| Version  | Download Link|
| ------------ | ------------ |
| Office 365 Professional Plus | <http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/O365ProPlusRetail.img> |
| Office 365 Business | <http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/O365BusinessRetail.img> |
| Office 365 Home Premium | <http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/O365HomePremRetail.img> |
| Office 2019 Professional Plus | <https://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/ProPlus2019Retail.img> |
| Office 2016 Professional Plus | <https://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/ProPlusRetail.img> |
| Office 2013 Professional | <https://officeredir.microsoft.com/r/rlidO15C2RMediaDownload?p1=db&p2=en-US&p3=ProfessionalRetail> |
| Visio 2019 Professional | <https://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/VisioPro2019Retail.img> |
| Visio 2016 Professional | <http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/VisioProRetail.img> |
| Visio 2016 Standard | <http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/VisioStdRetail.img> |
| Project 2019 Professional | <https://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/ProjectPro2019Retail.img> |
| Project 2016 Professional | <http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/ProjectProRetail.img> |
| Project 2016 Standard | <http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/ProjectStdRetail.img> |
| Outlook 2016 | <http://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/OutlookRetail.img> |

</details>

<details>
<summary markdown="span"> BIOS Keys</summary>

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

<details>
<summary markdown="span"> IP BlackLists</summary>

|Category|Name|Description|Source|Header/Label|
|:----|:----|:----|:----|:----|
|Anonymizers|dan.me.uk|This list contains a full list of all TOR nodes|<https://www.dan.me.uk/torlist/>|Anon_TOR|
|Anonymizers|MaxMind|MaxMind.com sample list of high-risk IP addresses.|<https://www.maxmind.com/en/high-risk-ip-sample-list>|Anon_MaxMind|
|Attacks|Talos|TalosIntel.com List of known malicious network threats|<http://talosintel.com/feeds/ip-filter.blf>|Talos|
|Attacks|BadIPs 15d|Bad IPs in category any with score above 2 and age less than 15d|<https://www.badips.com/get/list/any/2?age=15d>|BadIPs_15d|
|Attacks|BadIPs 30d|BadIPs.com Bad IPs in category any with score above 2 and age less than 30d|<https://www.badips.com/get/list/any/2?age=30d>|BadIPs_30d|
|Attacks|Blocklist.de|Blocklist.de IPs that have been detected by fail2ban in the last 48 hours|<http://lists.blocklist.de/lists/all.txt>|Blocklist.de|
|Attacks|Cyber Crime WHQ|Block IPs|<https://cybercrime-tracker.net/fuckerz.php>|Cyber_Crime|
|Attacks|ISC_1d|<https://isc.sans.edu/api/sources/attacks/1000/1?text>|<https://cinsarmy.com/list/ci-badguys.txt>| |
|Attacks|Emerging Threats and DShield - Block IPs|This is combines several lists. At the moment of writing the blocklist contains the following:
Several malware C&C servers (Feodo, Zeus, Spyeye, Palevo).
Spamhaus drop list
DShield top 20 attackers. DShield provides a platform for users of firewalls to share intrusion information|<https://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt>|ET_Block_IP|
|Attacks|Emerging Threats and DShield - Compromised IPs|Compromised IPs|<https://rules.emergingthreats.net/blockrules/compromised-ips.txt>|ET_Comp_IP|
|Attacks|GreenSnow|GreenSnow.co the blacklisted list of IPs for online servers.|<https://blocklist.greensnow.co/greensnow.txt>|GreenSnow|
| |MyIP.ms|Our sites are visited by tens of thousands of people every day. Our unique protection system allows us to easily identify the IP of Unknown Spam Bots / Crawlers and other IP with dangerous software. Below are published in real time our blacklist of such IP's. Hope it will be helpful for you. Read More|<https://www.myip.ms/files/blacklist/general/latest_blacklist.txt>|MyIP_ms|
|Attacks|Internet Storm Center|IP Block List|<https://isc.sans.edu/api/sources/attacks/1000/30?text>|ISC_30d|
|Attacks|NormShield|NormShield.com IPs in category attack with severity all|<https://iplists.firehol.org/files/normshield_all_attack.ipset>|NormShield_All|
|Attacks|Snort IPfilter|Same as TALOS|<http://labs.snort.org/feeds/ip-filter.blf>|SnortIPfilter|
|Malware|Abuse.ch Feodo|Included in RW. Abuse.ch Feodo tracker trojan includes IPs which are being used by Feodo (also known as Cridex or Bugat) which commits ebanking fraud|<https://feodotracker.abuse.ch/blocklist/?download=ipblocklist>|Abusech_Feodo|
|Malware|Abuse.ch Ransomware Tracker Feed|Abuse.ch Ransomware Tracker Ransomware Tracker tracks and monitors the status of domain names, IP addresses and URLs that are associated with Ransomware, such as Botnet C&C servers, distribution sites and payment sites.|<https://ransomwaretracker.abuse.ch/feeds/csv/>|Abusech_Feed|
|Malware|Abuse.ch Ransomware Tracker RW|Abuse.ch Ransomware Tracker Ransomware Tracker tracks and monitors the status of domain names, IP addresses and URLs that are associated with Ransomware, such as Botnet C&C servers, distribution sites and payment sites.|<https://ransomwaretracker.abuse.ch/downloads/RW_IPBL.txt>|Abusech_RW|
|Malware|Abuse.ch SSL Blacklist Agressive|Abuse.ch SSL Blacklist The aggressive version of the SSL IP Blacklist contains all IPs that SSLBL ever detected being associated with a malicious SSL certificate|<https://sslbl.abuse.ch/blacklist/sslipblacklist_aggressive.csv>|Abusech_sslbl|
|Malware|Abuse.ch Zeus|Included in RW. Abuse.ch Zeus tracker standard, contains the same data as the ZeuS IP blocklist (zeus_badips) but with the slight difference that it doesn't exclude hijacked websites (level 2) and free web hosting providers (level 3)|<https://zeustracker.abuse.ch/blocklist.php?download=ipblocklist>|Abusech_Zeus|
|Malware|Bambenek|Master Feed of known, active and non-sinkholed C&Cs IP addresses|<https://osint.bambenekconsulting.com/feeds/c2-ipmasterlist.txt>|Bambenek_All|
|Malware|IBM X-Force|IBM X-Force Exchange Botnet Command and Control Servers|<https://iplists.firehol.org/files/xforce_bccs.ipset>|IBM_XForce|
|Malware|Malc0de|Malc0de.com malicious IPs of the last 30 days|<http://malc0de.com/bl/IP_Blacklist.txt>|Malc0de|
|Malware|MalwareDomainList|malwaredomainlist.com list of malware active ip addresses|<http://www.malwaredomainlist.com/hostslist/ip.txt>|MalwareDomainList|
|Malware|URLVir|URLVir.com Active Malicious IP Addresses Hosting Malware. URLVir is an online security service developed by NoVirusThanks Company Srl that automatically monitors changes of malicious URLs (executable files)|<http://www.urlvir.com/export-ip-addresses/>|URLVir|
|Malware|VxVault|VxVault The latest 100 additions of VxVault.|<http://vxvault.net/ViriList.php?s=0&m=100>|VxVault|
|Reputation|AlienVault|AlienVault.com IP reputation database|<https://reputation.alienvault.com/reputation.generic>|AlienVault|
|Reputation|Binary Defense|Binary Defense Systems Artillery Threat Intelligence Feed and Banlist Feed|<https://www.binarydefense.com/banlist.txt>|BinaryDefense|
|Reputation|CINS Army|CIArmy.com IPs with poor Rogue Packet score that have not yet been identified as malicious by the community|<http://cinsscore.com/list/ci-badguys.txt>|CINS_Army|
|Attacks|ISCBlock| |<https://isc.sans.edu/feeds/block.txt>| |
|Anonymizers|ProxyLists_1d| |<https://iplists.firehol.org/files/proxylists_1d.ipset>| |
|Malware|Abuse_DYRE| |<https://sslbl.abuse.ch/blacklist/dyre_sslipblacklist.csv>| |

</details>
