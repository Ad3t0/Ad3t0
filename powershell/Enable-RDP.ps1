# === Settings ===
$rdpRegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server'
$rdpRegistryValue = 'fDenyTSConnections'
$rdpFirewallRules = @(
    'RemoteDesktop-UserMode-In-TCP',
    'RemoteDesktop-UserMode-In-UDP'
)

# === Confirmation ===
Write-Host "This script will enable Remote Desktop, configure firewall rules, and optionally add users to the Remote Desktop Users group." -ForegroundColor Yellow
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

# === Add Users to Remote Desktop Users group ===
Write-Host "Checking for local users to add to Remote Desktop Users group..." -ForegroundColor Cyan

# Get all local users, administrators, and RDP users
$localUsers = Get-LocalUser | Where-Object { $_.Enabled -eq $true }

function Get-LocalGroupMembers-ADSI ($groupName) {
    $group = [ADSI]"WinNT://$env:COMPUTERNAME/$groupName,group"
    $members = @($group.psbase.Invoke("Members"))
    $members | ForEach-Object {
        $name = $_.GetType().InvokeMember("Name", "GetProperty", $null, $_, $null)
        $path = $_.GetType().InvokeMember("ADsPath", "GetProperty", $null, $_, $null)
        $sid = New-Object System.Security.Principal.SecurityIdentifier($_.GetType().InvokeMember("objectSid", "GetProperty", $null, $_, $null), 0)
        [PSCustomObject]@{
            Name = $name
            ADsPath = $path
            SID = $sid.Value
        }
    }
}

$admins = Get-LocalGroupMembers-ADSI -groupName "Administrators"
$rdpUsers = Get-LocalGroupMembers-ADSI -groupName "Remote Desktop Users"

# Find users that are not admins and not already in the RDP group
$usersToAdd = $localUsers | Where-Object { ($_.SID -notin $admins.SID) -and ($_.SID -notin $rdpUsers.SID) }

if ($usersToAdd) {
    Write-Host "The following users are not administrators and not in the Remote Desktop Users group:" -ForegroundColor Yellow
    for ($i = 0; $i -lt $usersToAdd.Count; $i++) {
        Write-Host "[$($i+1)] $($usersToAdd[$i].Name)"
    }

    $selection = Read-Host "Enter the numbers of the users to add (e.g., 1,3,4), or 'A' for all"
    if ($selection) {
        $selectedUsers = @()
        if ($selection -eq 'A') {
            $selectedUsers = $usersToAdd
        } else {
            $indices = $selection -split ',' | ForEach-Object { $_.Trim() } | ForEach-Object { [int]$_ - 1 }
            foreach ($index in $indices) {
                if ($index -ge 0 -and $index -lt $usersToAdd.Count) {
                    $selectedUsers += $usersToAdd[$index]
                }
            }
        }

        if ($selectedUsers) {
            foreach ($user in $selectedUsers) {
                Write-Host "Adding $($user.Name) to Remote Desktop Users group..." -ForegroundColor Cyan
                Add-LocalGroupMember -Group "Remote Desktop Users" -Member $user.Name
            }
            Write-Host "Selected users added successfully." -ForegroundColor Green
        } else {
            Write-Host "No valid users selected." -ForegroundColor Yellow
        }
    } else {
        Write-Host "No users were selected." -ForegroundColor Yellow
    }
} else {
    Write-Host "No users found that need to be added to the Remote Desktop Users group." -ForegroundColor Green
}

Write-Host "Remote Desktop has been enabled and firewall rules configured." -ForegroundColor Green
