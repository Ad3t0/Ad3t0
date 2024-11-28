# Initial profile listing and filtering
$AllProfiles = Get-CimInstance -Class Win32_UserProfile | Where-Object {
    -not $_.Special -and
    $_.LocalPath -notlike '*\ServiceProfiles\*' -and
    $_.LocalPath -notlike '*\systemprofile'
}

# Get current user with proper case sensitivity
$CurrentUserIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$CurrentDomain = $CurrentUserIdentity.Name.Split('\')[0]
$CurrentUser = $CurrentUserIdentity.Name.Split('\')[1]

# Function to get folder size using robocopy
function Get-FolderSize {
    param($Path)

    $tempFile = [System.IO.Path]::GetTempFileName()
    robocopy $Path NULL /L /XJ /R:0 /W:0 /NP /E /BYTES /NFL /NDL /NJH /MT:64 | Out-File $tempFile
    $size = (Get-Content $tempFile | Select-String "Bytes :").ToString().Split(":")[1].Trim().Split(" ")[0]
    Remove-Item $tempFile -Force
    return [long]$size
}

Write-Host "`nEnumerating profile sizes, please wait...`n" -ForegroundColor Yellow

Write-Host "User Profiles on this system:`n" -ForegroundColor Cyan
foreach ($Profile in $AllProfiles) {
    $Username = $Profile.LocalPath.Split('\')[-1]
    $LastUse = if ($Profile.LastUseTime) { [DateTime]$Profile.LastUseTime } else { "Never" }
    $DaysSinceUse = if ($LastUse -is [DateTime]) {
        [math]::Round(((Get-Date) - $LastUse).TotalDays, 0)
    } else {
        "N/A"
    }
    $Status = if ($Profile.Loaded) { "IN USE" } else { "Not Active" }

    # Get profile size using robocopy
    $Size = Get-FolderSize -Path $Profile.LocalPath
    $SizeGB = [math]::Round($Size / 1GB, 2)
    $SizeString = "$($SizeGB) GB"

    Write-Host "Username        : $($Username)"
    Write-Host "Profile Path    : $($Profile.LocalPath)"
    Write-Host "Profile Size    : $($SizeString)"
    Write-Host "Last Used       : $($LastUse)"
    Write-Host "Days Inactive   : $($DaysSinceUse)"
    Write-Host "Status          : $($Status)"

    # Check if this is current user's profile
    if ($CurrentUser -eq $Username) {
        Write-Host "NOTE            : This is your current profile" -ForegroundColor Yellow
    }
    Write-Host "------------------------"
}

# Check if there are any profiles available for deletion
$DeletableProfiles = $AllProfiles | Where-Object { -not $_.Loaded }

if ($DeletableProfiles.Count -eq 0) {
    Write-Host "`nNo profiles are available for deletion. All profiles are currently in use." -ForegroundColor Yellow
    exit
}

# Menu for deletion options
Write-Host "`nProfile Deletion Options:" -ForegroundColor Yellow
Write-Host "1. Delete by username wildcard (e.g., 'old*' or '*admin')"
Write-Host "2. Delete by inactivity period (X days)"
Write-Host "3. Delete specific profile"
Write-Host "4. Exit"

$Choice = Read-Host "`nEnter your choice (1-4)"

switch ($Choice) {
    "1" {
        $WildCard = Read-Host "Enter username wildcard pattern"
        $ProfilesToDelete = $DeletableProfiles | Where-Object {
            $_.LocalPath.Split('\')[-1] -like $WildCard
        }
    }
    "2" {
        $DaysInactive = Read-Host "Enter number of days of inactivity"
        if (-not [int]::TryParse($DaysInactive, [ref]$null)) {
            Write-Host "Invalid number entered. Exiting..." -ForegroundColor Red
            exit
        }
        $ProfilesToDelete = $DeletableProfiles | Where-Object {
            $_.LastUseTime -and ((Get-Date) - [DateTime]$_.LastUseTime).Days -ge $DaysInactive
        }
    }
    "3" {
        $SpecificUser = Read-Host "Enter exact username to delete"
        $ProfilesToDelete = $DeletableProfiles | Where-Object {
            $_.LocalPath.Split('\')[-1] -eq $SpecificUser
        }
    }
    "4" {
        Write-Host "Exiting script..." -ForegroundColor Yellow
        exit
    }
    default {
        Write-Host "Invalid choice. Exiting..." -ForegroundColor Red
        exit
    }
}

# Display profiles to be removed
if ($ProfilesToDelete -and $ProfilesToDelete.Count -gt 0) {
    Write-Host "`nProfiles that will be removed:`n" -ForegroundColor Yellow
    $TotalSize = 0
    foreach ($Profile in $ProfilesToDelete) {
        $Username = $Profile.LocalPath.Split('\')[-1]
        $LastUse = if ($Profile.LastUseTime) { [DateTime]$Profile.LastUseTime } else { "Never" }
        $DaysSinceUse = if ($Profile.LastUseTime) {
            ((Get-Date) - [DateTime]$Profile.LastUseTime).Days
        } else {
            "Unknown"
        }

        # Get profile size using robocopy
        $Size = Get-FolderSize -Path $Profile.LocalPath
        $TotalSize += $Size
        $SizeGB = [math]::Round($Size / 1GB, 2)
        $SizeString = "$($SizeGB) GB"

        Write-Host "Username        : $($Username)" -ForegroundColor Cyan
        Write-Host "Profile Path    : $($Profile.LocalPath)"
        Write-Host "Profile Size    : $($SizeString)"
        Write-Host "Last Used       : $($LastUse)"
        Write-Host "Days Inactive   : $($DaysSinceUse)"
        Write-Host "------------------------"
    }

    Write-Host "`nTotal profiles to remove: $($ProfilesToDelete.Count)" -ForegroundColor Yellow
    if ($TotalSize -gt 0) {
        $TotalSizeGB = [math]::Round($TotalSize / 1GB, 2)
        Write-Host "Total space to be freed: $($TotalSizeGB) GB" -ForegroundColor Yellow
    }

    # Check for Administrator profile
    if ($ProfilesToDelete | Where-Object { $_.LocalPath.Split('\')[-1] -eq 'Administrator' }) {
        Write-Host "`nWARNING: You are attempting to delete the local Administrator profile!" -ForegroundColor Red
        Write-Host "This is generally not recommended unless the profile is corrupted." -ForegroundColor Red
        $AdminConfirm = Read-Host "Are you absolutely sure you want to continue? Type 'YES' to confirm"
        if ($AdminConfirm -ne 'YES') {
            Write-Host "`nOperation cancelled." -ForegroundColor Yellow
            exit
        }
    }

    # Regular confirmation
    $Confirm = Read-Host "`nDo you want to proceed with deletion? (Y/N)"

    if ($Confirm -eq 'Y') {
        foreach ($Profile in $ProfilesToDelete) {
            try {
                Remove-CimInstance -InputObject $Profile
                Write-Host "Deleted: $($Profile.LocalPath)" -ForegroundColor Green
            } catch {
                Write-Host "Error deleting $($Profile.LocalPath): $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "`nOperation cancelled by user." -ForegroundColor Yellow
    }
} else {
    Write-Host "No profiles found matching the selected criteria." -ForegroundColor Yellow
}