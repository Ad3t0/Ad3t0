# Useful scripts and notes for system administration and engineering

<details>
<summary>PowerShell Scripts</summary>

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
<summary>Bash Scripts</summary>

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

<details>
<summary>IP BlackLists</summary>

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
