# PowerShell Profile Migration Script with EDR/AV Decoy Exclusions
#
# This script migrates user profile data while excluding EDR/AV canary files and decoys
# Supported EDR platforms for exclusions:
# - SentinelOne (afterSentDocuments folders, hex-named decoy files)
# - VMware Carbon Black Cloud (8-char hex canary files)
# - Palo Alto Cortex XDR (Cyvera ransomware decoys)
# - Huntress Ransomware Canaries (hidden folders in Documents)
# - WatchGuard EPDR/Adaptive Defense (temp folders)
#
# Also excludes Windows junction points like "My Pictures" to prevent duplicate data

# Define directories to ignore during profile migration
# Based on EDR decoys, temp files, cache folders, and other problematic directories
# Note: Robocopy-compatible patterns only (no complex paths with backslashes)
$ignoreDirectories = @(
    # SentinelOne EDR decoys and honeypots
    "afterSentDocuments",

    # VMware Carbon Black Cloud canary directories
    "CarbonBlack",
    "CB",

    # Palo Alto Cortex XDR ransomware decoys
    "Cyvera",
    "Ransomware",

    # WatchGuard EPDR / Adaptive Defense temp folders
    "TEMP.*",

    # General EDR/AV temp and cache directories
    "Temp",
    "Cache",
    "tmp",
    "cache2",

    # Browser cache directories (simple names only)
    "CachedData",
    "GPUCache",
    "ShaderCache",

    # Sync service caches
    "OneDriveTemp",

    # Windows system directories
    "Recent",
    "Thumbs",
    "thumbnails",

    # Windows folder redirection/junction points (prevent duplicates)
    "My Pictures",
    "My Music",
    "My Videos",
    "My Documents",

    # Recycle Bin (escaped dollar sign)
    '$Recycle.Bin',
    "RECYCLER"
)

# Define file patterns to ignore during profile migration
$ignoreFiles = @(
    # Standard exclusions
    "*.lnk",           # Shortcuts (already excluded)
    "*.ini",           # Config files (already excluded)
    "*.tmp",           # Temporary files
    "*.temp",          # Temporary files
    "*.log",           # Log files
    "*.cache",         # Cache files
    "Thumbs.db",       # Windows thumbnail cache
    "desktop.ini",     # Windows folder settings
    "*.bak",           # Backup files
    "~*",              # Office temporary files

    # EDR/AV canary file patterns
    # SentinelOne hex-named files (32 chars starting with $)
    '$????????????????????????????????.*',

    # VMware Carbon Black canary files (8-char uppercase hex prefix)
    '$????????.doc',
    '$????????.jpg',
    '$????????.xls',
    '$????????.pptx',

    # General EDR decoy patterns
    "*.decoy",
    "canary*.*",
    "honeypot*.*"
)

Write-Host "Ignore list contains $($ignoreDirectories.Count) directory patterns and $($ignoreFiles.Count) file patterns" -ForegroundColor Yellow

# Get a list of all user profiles on the system
$userProfiles = Get-WmiObject -Class Win32_UserProfile | Where-Object { $_.Special -eq $false }

# Display each profile with an index number
Write-Host "Select a user profile to migrate by typing the corresponding number:" -ForegroundColor Cyan
for ($i = 0; $i -lt $userProfiles.Count; $i++) {
	Write-Host "$($i + 1)): $($userProfiles[$i].LocalPath)"
}

# Prompt the user to select a profile
[INT]$selection = 0
do {
	$inputPath = Read-Host "Enter profile to migrate"
	$selection = $inputPath -as [INT]
	$isValid = $selection -ge 1 -and $selection -le $userProfiles.Count
	if (-not $isValid) {
		Write-Host "Invalid selection, please try again." -ForegroundColor Red
	}
} while (-not $isValid)

# Display the selected user profile path
$selectedProfile = $userProfiles[$selection - 1]
Write-Host "You have selected the profile at: $($selectedProfile.LocalPath)" -ForegroundColor Green

# Function to check if a path is accessible
function Test-PathAccess {
	param (
		[string]$Path
	)

	# Test if the path exists and catch any exceptions that indicate access issues
	try {
		$null = Get-Item $Path -ErrorAction Stop
		return $true
	}
 catch {
		Write-Host "Error accessing path: $($_.Exception.Message)" -ForegroundColor Red
		return $false
	}
}

# Main script to prompt for path input and validate
do {
	# Prompt the user for a path
	$destinationPath = Read-Host "Please enter a destination path"

	# Test the path
	$pathIsValid = Test-PathAccess -Path $destinationPath
	if (-not $pathIsValid) {
		Write-Host "Please provide a valid and accessible destination path." -ForegroundColor Yellow
	}

} while (-not $pathIsValid)

Write-Host "Using the destination path '$destinationPath'." -ForegroundColor Green

# Ask user if they want to compress the data
$compressChoice = Read-Host "Do you want to compress the exported data with 7zip? (y/n)"

$username = $selectedProfile.LocalPath -split "\\"
$username = $username[2]

# Get all items in the base path that start with 'OneDrive' but are not exactly named 'OneDrive'
$targetDirectory = Get-ChildItem -Path $($selectedProfile.LocalPath) -Directory | Where-Object {
	$_.Name -like "OneDrive*" -and $_.Name -ne "OneDrive"
}

# Check if a directory was found and store the full path
if ($targetDirectory) {
	$exactPath = $targetDirectory.FullName
	Write-Output "OneDrive profile syncing detected using path: $exactPath"

	New-Item -ItemType Directory -Path "$($destinationPath)\$($username)\OneDrive" -ErrorAction SilentlyContinue

	robocopy $exactPath "$($destinationPath)\$($username)\OneDrive" /S /DCOPY:DA /COPY:DAT /R:1000000 /W:30 /XF $ignoreFiles /XD $ignoreDirectories

}

$documentsPath = "$($selectedProfile.LocalPath)\Documents"
$desktopPath = "$($selectedProfile.LocalPath)\Desktop"
$picturesPath = "$($selectedProfile.LocalPath)\Pictures"

New-Item -ItemType Directory -Path "$($destinationPath)\$($username)\Documents" -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path "$($destinationPath)\$($username)\Desktop" -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path "$($destinationPath)\$($username)\Pictures" -ErrorAction SilentlyContinue

Write-Host "Starting profile migration with exclusions..." -ForegroundColor Cyan
Write-Host "Excluded directories: $($ignoreDirectories -join ', ')" -ForegroundColor Yellow
Write-Host "Excluded file patterns: $($ignoreFiles -join ', ')" -ForegroundColor Yellow

robocopy $documentsPath "$($destinationPath)\$($username)\Documents" /S /DCOPY:DA /COPY:DAT /R:1000000 /W:30 /XF $ignoreFiles /XD $ignoreDirectories
robocopy $desktopPath "$($destinationPath)\$($username)\Desktop" /S /DCOPY:DA /COPY:DAT /R:1000000 /W:30 /XF $ignoreFiles /XD $ignoreDirectories
robocopy $picturesPath "$($destinationPath)\$($username)\Pictures" /S /DCOPY:DA /COPY:DAT /R:1000000 /W:30 /XF $ignoreFiles /XD $ignoreDirectories

if (Test-Path -Path "$($selectedProfile.LocalPath)\AppData\Local\Google\Chrome\User Data\Default\Bookmarks") {
	$ChromeBookmarksPath = "$($selectedProfile.LocalPath)\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"
	$ExportFile = "$($destinationPath)\$($username)\chrome_bookmarks.html"
	Copy-Item -Path $ChromeBookmarksPath -Destination $ExportFile
}
if ($compressChoice -eq 'y') {
    Write-Host "Attempting to compress data..." -ForegroundColor Green
    $sourceDir = "$($destinationPath)\$($username)"
    $archiveFile = "$($destinationPath)\$($username)_profile_backup.7z" # Output file in the root of destinationPath

    # Attempt to find 7z.exe
    $7zipExePath = $null
    $commonPaths = @(
        "C:\Program Files\7-Zip\7z.exe",
        "C:\Program Files (x86)\7-Zip\7z.exe"
    )

    foreach ($path in $commonPaths) {
        if (Test-Path $path -PathType Leaf) {
            $7zipExePath = $path
            break
        }
    }

    if (-not $7zipExePath) {
        # Check PATH if not found in common locations
        if (Get-Command 7z.exe -ErrorAction SilentlyContinue) {
            $7zipExePath = "7z.exe" # Found in PATH
        } else {
            Write-Host "7zip command (7z.exe) not found in common locations or PATH. Please install 7zip." -ForegroundColor Red
            Write-Host "Skipping compression." -ForegroundColor Yellow
        }
    }

    if ($7zipExePath) {
        Write-Host "Using 7zip: $7zipExePath" -ForegroundColor Cyan
        $arguments = @(
            "a", # Add to archive
            "-t7z", # Set archive type to 7z
            "-y",   # Assume Yes on all queries from 7-Zip
            $archiveFile, # Output archive file path
            "$($sourceDir)\*" # Source files/folders to compress (contents of the user's profile backup)
        )

        try {
            Write-Host "Starting compression of '$sourceDir' to '$archiveFile'..." -ForegroundColor Green
            # Execute 7zip. Using Start-Process to ensure it runs correctly, especially if path has spaces.
            # Using -Wait to ensure script waits for compression to finish.
            # Using -PassThru to get process object, then checking ExitCode.
            $process = Start-Process -FilePath $7zipExePath -ArgumentList $arguments -Wait -NoNewWindow -PassThru

            if ($process.ExitCode -eq 0) {
                Write-Host "Data compressed successfully to '$archiveFile'" -ForegroundColor Green

                # Remove the uncompressed source directory to avoid duplicate data
                try {
                    Write-Host "Removing uncompressed source directory to avoid duplicate data..." -ForegroundColor Yellow
                    Remove-Item -Path $sourceDir -Recurse -Force
                    Write-Host "Uncompressed source directory removed successfully." -ForegroundColor Green
                } catch {
                    Write-Host "Warning: Could not remove uncompressed source directory: $($_.Exception.Message)" -ForegroundColor Yellow
                    Write-Host "You may want to manually delete '$sourceDir' to avoid duplicate data." -ForegroundColor Yellow
                }
            } else {
                Write-Host "7zip process completed with exit code $($process.ExitCode). There might have been an issue during compression." -ForegroundColor Yellow
                Write-Host "Please check 7zip logs or output if available. The archive might be incomplete or corrupted." -ForegroundColor Yellow
                Write-Host "Keeping uncompressed data due to compression issues." -ForegroundColor Yellow
            }
        } catch {
            Write-Host "Error executing 7zip compression: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Full command attempted: $7zipExePath $($arguments -join ' ')" -ForegroundColor Red
        }
    }
} else {
    Write-Host "Skipping compression." -ForegroundColor Yellow
}

Write-Host "Profile migration process complete." -ForegroundColor Cyan