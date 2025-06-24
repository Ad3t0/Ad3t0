# Prompt for configuration
$ZABBIX_PROXY_HOST = Read-Host "Enter Zabbix proxy/server IP address"
$HOST_PREFIX = Read-Host "Enter host prefix (leave empty to use hostname only)"
$ZABBIX_VERSION_INPUT = Read-Host "Enter Zabbix version (6, 7, or specific like 7.0.12, default is 7)"

# Determine full version based on input
if ([string]::IsNullOrWhiteSpace($ZABBIX_VERSION_INPUT)) {
    # Default to latest major version if nothing provided
    $ZABBIX_VERSION = "7.0.12"  # Latest 7.0.x version
} elseif ($ZABBIX_VERSION_INPUT -eq "6") {
    $ZABBIX_VERSION = "6.4.21"  # Latest 6.x version
} elseif ($ZABBIX_VERSION_INPUT -eq "7") {
    $ZABBIX_VERSION = "7.0.12"  # Latest 7.0.x version
} elseif ($ZABBIX_VERSION_INPUT -match '^\d+\.\d+$') {
    # Major.Minor version provided (e.g. "6.4" or "7.0")
    $latestPatchVersions = @{
        "6.4" = "6.4.21"
        "7.0" = "7.0.12"
        "7.2" = "7.2.6"
    }

    if ($latestPatchVersions.ContainsKey($ZABBIX_VERSION_INPUT)) {
        $ZABBIX_VERSION = $latestPatchVersions[$ZABBIX_VERSION_INPUT]
    } else {
        Write-Host "Unsupported version format. Using latest version 7.0.12." -ForegroundColor Yellow
        $ZABBIX_VERSION = "7.0.12"
    }
} elseif ($ZABBIX_VERSION_INPUT -match '^\d+\.\d+\.\d+$') {
    # Full version provided
    $ZABBIX_VERSION = $ZABBIX_VERSION_INPUT
} else {
    # Invalid format, use default
    Write-Host "Invalid version format. Using latest version 7.0.12." -ForegroundColor Yellow
    $ZABBIX_VERSION = "7.0.12"
}

# Check for VM and prompt for SMART monitoring
$wantsSMARTMonitoring = $false
$isVM = (Get-WmiObject -Class Win32_ComputerSystem).Model -match "Virtual"
if ($isVM) {
    Write-Host "`nMachine is a VM, SMART monitoring is not applicable." -ForegroundColor Yellow
} else {
    $enableSMARTChoice = Read-Host "Enable SMART disk monitoring? (Y/N)"
    if ($enableSMARTChoice -match '^[Yy]$') {
        $wantsSMARTMonitoring = $true
    }
}

# Display installation summary
Write-Host "`n=== Installation Summary ===" -ForegroundColor Cyan
Write-Host "Zabbix Server/Proxy: $ZABBIX_PROXY_HOST" -ForegroundColor Yellow
Write-Host "Host Prefix: $(if([string]::IsNullOrWhiteSpace($HOST_PREFIX)){"None"}else{$HOST_PREFIX})" -ForegroundColor Yellow
Write-Host "Zabbix Version: $ZABBIX_VERSION" -ForegroundColor Yellow
Write-Host "Target System: $env:COMPUTERNAME" -ForegroundColor Yellow
Write-Host "SMART Monitoring: $(if($wantsSMARTMonitoring) {'Enabled'} else {'Disabled'})" -ForegroundColor Yellow

# Confirm installation
$confirm = Read-Host "`nDo you want to proceed with the installation? (Y/N)"
if ($confirm -notmatch '^[Yy]$') {
    Write-Host "Installation cancelled." -ForegroundColor Red
    exit
}

# Check for and remove old Zabbix Agent
$oldAgent = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Zabbix Agent*" -and $_.Name -notlike "*Zabbix Agent 2*" }
if ($oldAgent) {
    Write-Host "`nFound old Zabbix Agent installation. Removing..." -ForegroundColor Yellow

    # Stop the old agent service if it exists
    if (Get-Service "Zabbix Agent" -ErrorAction SilentlyContinue) {
        Stop-Service "Zabbix Agent" -Force
    }

    # Uninstall the old agent
    $oldAgent.Uninstall()

    Write-Host "Old Zabbix Agent removed successfully." -ForegroundColor Green
}

# Configuration variables
$INSTALL_DIR = "C:\Program Files\Zabbix Agent 2"
$PSK_DIR = "$INSTALL_DIR\psk"
$CONFIG_DIR = "$INSTALL_DIR\conf"

# Get system hostname and create prefixed version if prefix is provided
$SYSTEM_HOSTNAME = $env:COMPUTERNAME.ToLower()
if ([string]::IsNullOrWhiteSpace($HOST_PREFIX)) {
    $PREFIXED_HOSTNAME = $SYSTEM_HOSTNAME
} else {
    $PREFIXED_HOSTNAME = "$($HOST_PREFIX)-$($SYSTEM_HOSTNAME)"
}
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

# Stop existing Zabbix Agent 2 service if running
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
# Install smartmontools and update config if requested
if ($wantsSMARTMonitoring) {
    Write-Host "`nInstalling smartmontools via Chocolatey..." -ForegroundColor Cyan
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install smartmontools -y --force
        $smartPluginLine = "`n# SMART Monitoring`nPlugins.Smart.Path=C:\Program Files\smartmontools\bin\smartctl.exe"
        Add-Content -Path "$INSTALL_DIR\zabbix_agent2.conf" -Value $smartPluginLine
        Write-Host "SMART monitoring enabled." -ForegroundColor Green
    } else {
        Write-Host "Chocolatey is not installed. Cannot install smartmontools. Skipping." -ForegroundColor Red
    }
}

# Set file permissions
$acl = Get-Acl "$PSK_DIR\zabbix.psk"
$acl.SetAccessRuleProtection($true, $false)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM","FullControl","Allow")
$acl.AddAccessRule($rule)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")
$acl.AddAccessRule($rule)
Set-Acl "$PSK_DIR\zabbix.psk" $acl

# Restart Zabbix Agent 2 service
Start-Sleep -Seconds 15
Restart-Service "Zabbix Agent 2" -Force
Start-Sleep -Seconds 2

# Create firewall rule
New-NetFirewallRule -DisplayName "Zabbix Agent 2" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 10050 -Program "$INSTALL_DIR\zabbix_agent2.exe"

# Display configuration information
Write-Host "`n=== Configuration Information ===" -ForegroundColor Cyan
Write-Host "System Hostname: $SYSTEM_HOSTNAME" -ForegroundColor Green
Write-Host "Zabbix Hostname: $PREFIXED_HOSTNAME" -ForegroundColor Green
if (![string]::IsNullOrWhiteSpace($HOST_PREFIX)) {
    Write-Host "Host Prefix: $HOST_PREFIX" -ForegroundColor Green
}
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