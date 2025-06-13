# === Settings ===
$rdpRegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server'
$rdpRegistryValue = 'fDenyTSConnections'
$rdpFirewallRules = @(
    'RemoteDesktop-UserMode-In-TCP',
    'RemoteDesktop-UserMode-In-UDP'
)

# === Confirmation ===
Write-Host "This script will enable Remote Desktop and configure firewall rules." -ForegroundColor Yellow
$confirmation = Read-Host "Continue? (Y/N)"
if ($confirmation -notin @('Y', 'y')) {
    Write-Host "Operation cancelled." -ForegroundColor Red
    exit
}

# === Enable RDP ===
Write-Host "Enabling Remote Desktop..." -ForegroundColor Cyan
Set-ItemProperty -Path $rdpRegistryPath -Name $rdpRegistryValue -Value 0

# === Enable Firewall Rules ===
foreach ($ruleName in $rdpFirewallRules) {
    Write-Host "Enabling firewall rule: $($ruleName)" -ForegroundColor Cyan
    Enable-NetFirewallRule -Name $ruleName
}

Write-Host "Remote Desktop has been enabled and firewall rules configured." -ForegroundColor Green
