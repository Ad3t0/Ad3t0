# Get all user profiles excluding system profiles
$AllProfiles = Get-CimInstance -Class Win32_UserProfile | Where-Object {
    -not $_.Special -and
    $_.LocalPath -match '^C:\\Users\\[^\\]+$'
}

# Get current user info
$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name.Split('\')[1]

# Function to get folder size using robocopy
function Get-FolderSize {
    param($Path)

    try {
        $tempFile = [System.IO.Path]::GetTempFileName()
        robocopy $Path NULL /L /XJ /R:0 /W:0 /NP /E /BYTES /NFL /NDL /NJH /MT:64 | Out-File $tempFile
        $size = (Get-Content $tempFile | Select-String "Bytes :").ToString().Split(":")[1].Trim().Split(" ")[0]
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
        return [long]$size
    }
    catch {
        return 0
    }
}

# Function to format size
function Format-Size {
    param([long]$Size)
    return "$([math]::Round($Size / 1GB, 2)) GB"
}

Write-Host "`nEnumerating profile sizes, please wait...`n" -ForegroundColor Yellow
Write-Host "User Profiles on this system:`n" -ForegroundColor Cyan

# Display all profiles
$ProfileList = foreach ($Profile in $AllProfiles) {
    $Username = $Profile.LocalPath.Split('\')[-1]
    $LastUse = if ($Profile.LastUseTime) { [DateTime]$Profile.LastUseTime } else { Get-Date }
    $DaysSinceUse = [math]::Round(((Get-Date) - $LastUse).TotalDays, 0)
    $Size = Get-FolderSize -Path $Profile.LocalPath
    $Status = if ($Profile.Loaded) { "IN USE" } else { "Not Active" }

    # Create custom object for each profile
    $ProfileInfo = [PSCustomObject]@{
        Username = $Username
        ProfilePath = $Profile.LocalPath
        Size = $Size
        SizeString = Format-Size -Size $Size
        LastUse = $LastUse
        DaysInactive = $DaysSinceUse
        Status = $Status
        Profile = $Profile
        IsCurrentUser = ($Username -eq $CurrentUser)
        IsLoaded = $Profile.Loaded
    }

    # Display profile information
    Write-Host "Username        : $($Username)"
    Write-Host "Profile Path    : $($Profile.LocalPath)"
    Write-Host "Profile Size    : $($ProfileInfo.SizeString)"
    Write-Host "Last Used       : $($LastUse)"
    Write-Host "Days Inactive   : $($DaysSinceUse)"
    Write-Host "Status          : $($Status)"

    if ($ProfileInfo.IsCurrentUser) {
        Write-Host "NOTE            : This is your current profile" -ForegroundColor Yellow
    }
    Write-Host "------------------------"

    $ProfileInfo
}

# Check for available profiles to delete
$DeletableProfiles = $ProfileList | Where-Object { -not $_.IsLoaded }

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

$ProfilesToDelete = switch ($Choice) {
    "1" {
        $WildCard = Read-Host "Enter username wildcard pattern"
        @($DeletableProfiles | Where-Object { $_.Username -like $WildCard })
    }
    "2" {
        $DaysInactive = Read-Host "Enter number of days of inactivity"
        if (-not [int]::TryParse($DaysInactive, [ref]$null)) {
            Write-Host "Invalid number entered. Exiting..." -ForegroundColor Red
            exit
        }
        @($DeletableProfiles | Where-Object { $_.DaysInactive -ge $DaysInactive })
    }
    "3" {
        $SpecificUser = Read-Host "Enter exact username to delete"
        @($DeletableProfiles | Where-Object { $_.Username -eq $SpecificUser })
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

if (($ProfilesToDelete | Measure-Object).Count -gt 0) {
    Write-Host "`nProfiles that will be removed:`n" -ForegroundColor Yellow
    $TotalSize = 0

    foreach ($Profile in $ProfilesToDelete) {
        $TotalSize += $Profile.Size
        Write-Host "Username        : $($Profile.Username)" -ForegroundColor Cyan
        Write-Host "Profile Path    : $($Profile.ProfilePath)"
        Write-Host "Profile Size    : $($Profile.SizeString)"
        Write-Host "Last Used       : $($Profile.LastUse)"
        Write-Host "Days Inactive   : $($Profile.DaysInactive)"
        Write-Host "------------------------"
    }

    Write-Host "`nTotal profiles to remove: $($ProfilesToDelete.Count)" -ForegroundColor Yellow
    Write-Host "Total space to be freed: $(Format-Size -Size $TotalSize)" -ForegroundColor Yellow

    # Administrator profile warning
    if ($ProfilesToDelete | Where-Object { $_.Username -eq 'Administrator' }) {
        Write-Host "`nWARNING: You are attempting to delete the local Administrator profile!" -ForegroundColor Red
        $AdminConfirm = Read-Host "Are you absolutely sure you want to continue? Type 'YES' to confirm"
        if ($AdminConfirm -ne 'YES') {
            Write-Host "`nOperation cancelled." -ForegroundColor Yellow
            exit
        }
    }

    $Confirm = Read-Host "`nDo you want to proceed with deletion? (Y/N)"

    if ($Confirm -eq 'Y') {
        foreach ($Profile in $ProfilesToDelete) {
            try {
                Remove-CimInstance -InputObject $Profile.Profile
                Write-Host "Deleted: $($Profile.ProfilePath)" -ForegroundColor Green
            }
            catch {
                Write-Host "Error deleting $($Profile.ProfilePath): $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    else {
        Write-Host "`nOperation cancelled by user." -ForegroundColor Yellow
    }
}
else {
    Write-Host "`nNo profiles found matching the selected criteria." -ForegroundColor Yellow
}