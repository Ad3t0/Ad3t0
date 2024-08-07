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

	robocopy $exactPath "$($destinationPath)\$($username)\OneDrive" /S /DCOPY:DA /COPY:DAT /R:1000000 /W:30 /XF *.lnk *.ini

}

$documentsPath = "$($selectedProfile.LocalPath)\Documents"
$desktopPath = "$($selectedProfile.LocalPath)\Desktop"
$picturesPath = "$($selectedProfile.LocalPath)\Pictures"

New-Item -ItemType Directory -Path "$($destinationPath)\$($username)\Documents" -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path "$($destinationPath)\$($username)\Desktop" -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path "$($destinationPath)\$($username)\Pictures" -ErrorAction SilentlyContinue

robocopy $documentsPath "$($destinationPath)\$($username)\Documents" /S /DCOPY:DA /COPY:DAT /R:1000000 /W:30 /XF *.lnk *.ini
robocopy $desktopPath "$($destinationPath)\$($username)\Desktop" /S /DCOPY:DA /COPY:DAT /R:1000000 /W:30 /XF *.lnk *.ini
robocopy $picturesPath "$($destinationPath)\$($username)\Pictures" /S /DCOPY:DA /COPY:DAT /R:1000000 /W:30 /XF *.lnk *.ini

if (Test-Path -Path "$($selectedProfile.LocalPath)\AppData\Local\Google\Chrome\User Data\Default\Bookmarks") {
	$ChromeBookmarksPath = "$($selectedProfile.LocalPath)\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"
	$ExportFile = "$($destinationPath)\$($username)\chrome_bookmarks.html"
	Copy-Item -Path $ChromeBookmarksPath -Destination $ExportFile
}