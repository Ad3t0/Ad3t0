# Prompt for configuration
$ZABBIX_PROXY_HOST = Read-Host "Enter Zabbix proxy/server IP address"
$HOST_PREFIX = Read-Host "Enter host prefix"

# Display installation summary
Write-Host "`n=== Installation Summary ===" -ForegroundColor Cyan
Write-Host "Zabbix Server/Proxy: $ZABBIX_PROXY_HOST" -ForegroundColor Yellow
Write-Host "Host Prefix: $HOST_PREFIX" -ForegroundColor Yellow
Write-Host "Target System: $env:COMPUTERNAME" -ForegroundColor Yellow

# Confirm installation
$confirm = Read-Host "`nDo you want to proceed with the installation? (Y/N)"
if ($confirm -notmatch '^[Yy]$') {
    Write-Host "Installation cancelled." -ForegroundColor Red
    exit
}

# Configuration variables
$ZABBIX_VERSION = "6.4.9"
$INSTALL_DIR = "C:\Program Files\Zabbix Agent 2"
$PSK_DIR = "$INSTALL_DIR\psk"
$CONFIG_DIR = "$INSTALL_DIR\conf"

# Get system hostname and create prefixed version
$SYSTEM_HOSTNAME = $env:COMPUTERNAME.ToLower()
$PREFIXED_HOSTNAME = "$($HOST_PREFIX)-$($SYSTEM_HOSTNAME)"
$PSK_IDENTITY = "WINDOWS-$($PREFIXED_HOSTNAME)"

# Create directory structure
New-Item -ItemType Directory -Force -Path $INSTALL_DIR, $PSK_DIR, $CONFIG_DIR | Out-Null

# Generate PSK
$random = New-Object byte[] 32
[System.Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($random)
$PSK = [System.BitConverter]::ToString($random) -replace '-',''
$PSK = $PSK.ToLower()
$PSK | Out-File -FilePath "$PSK_DIR\zabbix.psk" -Encoding ASCII -NoNewline

# Download Zabbix Agent 2
$arch = if ([Environment]::Is64BitOperatingSystem) { "amd64" } else { "i386" }
$url = "https://cdn.zabbix.com/zabbix/binaries/stable/$($ZABBIX_VERSION.Substring(0,3))/$ZABBIX_VERSION/zabbix_agent2-$ZABBIX_VERSION-windows-$arch-openssl.msi"
$installer = "$env:TEMP\zabbix_agent2.msi"

$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($url, $installer)

# Stop existing service if running
if (Get-Service "Zabbix Agent 2" -ErrorAction SilentlyContinue) {
    Stop-Service "Zabbix Agent 2" -Force
}

# Install Zabbix Agent 2
$arguments = "/i `"$installer`" /qn LOGTYPE=file LOGFILE=`"$INSTALL_DIR\zabbix_agent2.log`" SERVER=$ZABBIX_PROXY_HOST HOSTNAME=$PREFIXED_HOSTNAME"
Start-Process msiexec.exe -ArgumentList $arguments -Wait

# Update existing config if it exists
if (Test-Path "$INSTALL_DIR\zabbix_agent2.conf") {
    $currentConfig = Get-Content "$INSTALL_DIR\zabbix_agent2.conf"
    $currentConfig = $currentConfig | Where-Object {
        -not $_.StartsWith("ServerActive") -and
        -not $_.StartsWith("TLSConnect")
    }
    $currentConfig | Out-File "$INSTALL_DIR\zabbix_agent2.conf.bak" -Encoding ASCII
}

# Create new agent configuration
@"
LogFile=$INSTALL_DIR\zabbix_agent2.log
LogFileSize=0
LogType=file
DebugLevel=4

Server=$ZABBIX_PROXY_HOST
Hostname=$PREFIXED_HOSTNAME

# TLS PSK Configuration
TLSAccept=psk
TLSPSKIdentity=$PSK_IDENTITY
TLSPSKFile=$PSK_DIR\zabbix.psk
"@ | Out-File -FilePath "$INSTALL_DIR\zabbix_agent2.conf" -Encoding ASCII

# Set file permissions
$acl = Get-Acl "$PSK_DIR\zabbix.psk"
$acl.SetAccessRuleProtection($true, $false)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM","FullControl","Allow")
$acl.AddAccessRule($rule)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")
$acl.AddAccessRule($rule)
Set-Acl "$PSK_DIR\zabbix.psk" $acl

# Restart Zabbix Agent 2 service
Restart-Service "Zabbix Agent 2" -Force
Start-Sleep -Seconds 2

# Create firewall rule
New-NetFirewallRule -DisplayName "Zabbix Agent 2" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 10050 -Program "$INSTALL_DIR\zabbix_agent2.exe"

# Display configuration information
Write-Host "`n=== Configuration Information ===" -ForegroundColor Cyan
Write-Host "System Hostname: $SYSTEM_HOSTNAME" -ForegroundColor Green
Write-Host "Zabbix Hostname: $PREFIXED_HOSTNAME" -ForegroundColor Green
Write-Host "System IP: $((Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notmatch 'Loopback'}).IPAddress)" -ForegroundColor Green
Write-Host "PSK Identity: $PSK_IDENTITY" -ForegroundColor Green
Write-Host "PSK Key: $PSK" -ForegroundColor Green

# Display service status
Write-Host "`n=== Service Status ===" -ForegroundColor Cyan
Write-Host "Service Status: $((Get-Service 'Zabbix Agent 2').Status)" -ForegroundColor Green

Write-Host "`nNOTE: This agent is now configured for passive checks only." -ForegroundColor Yellow
Write-Host "Make sure to update your Zabbix frontend configuration:" -ForegroundColor Yellow
Write-Host "1. Configure host interface with this machine's IP and port 10050" -ForegroundColor Yellow
Write-Host "2. Update PSK encryption settings in frontend" -ForegroundColor Yellow
Write-Host "3. Switch to passive templates instead of active ones" -ForegroundColor Yellow

# Clean up and test
Remove-Item $installer -Force
& "$INSTALL_DIR\zabbix_agent2.exe" -t "agent.ping"