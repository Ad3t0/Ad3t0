# --- Settings ---
# Set to $true to run the script without any confirmation prompts (unattended mode).
$unattended = $false

# --- Setup ---
# Define a standard log directory path in ProgramData
Set-ExecutionPolicy -ExecutionPolicy Bypass -Force -Confirm:$false
$logDir = "C:\ProgramData\InstallAllUpdates"

# Create the log directory if it doesn't exist
if (-not (Test-Path -Path $logDir)) {
    # The -Force parameter creates parent directories if they don't exist
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

# Start logging all output to a timestamped file
$logFile = Join-Path -Path $logDir -ChildPath "InstallAllUpdates_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"
Start-Transcript -Path $logFile -Append

# Start a timer to measure the script's execution time
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# --- Main Logic ---
try {
    Write-Host "This script will automatically download and install all available Windows updates." -ForegroundColor Yellow
    if (-not $unattended) {
        $confirmation = Read-Host "Continue? (Y/N)"
        if ($confirmation -notin @('Y', 'y')) {
            Write-Host "Operation cancelled." -ForegroundColor Red
            # The 'finally' block will still execute to stop the transcript
            return
        }
    }

    Write-Host "Installing required PowerShell modules..." -ForegroundColor Cyan
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module -Name PSWindowsUpdate -Confirm:$False -Force
    Import-Module PSWindowsUpdate

    Write-Host "Registering Microsoft Update service..." -ForegroundColor Cyan
    Add-WUServiceManager -MicrosoftUpdate -Confirm:$false

    Write-Host "Searching for, downloading, and installing updates... This may take a while." -ForegroundColor Cyan
    # The -Verbose output from this command will be captured by the transcript
    $updates = Get-WindowsUpdate -MicrosoftUpdate -Install -AcceptAll -IgnoreReboot -Verbose

    # --- Summary ---
    $stopwatch.Stop()
    $duration = $stopwatch.Elapsed

    Write-Host "---" -ForegroundColor Green
    Write-Host "Update process complete." -ForegroundColor Green
    Write-Host "---" -ForegroundColor Green

    Write-Host "Summary:" -ForegroundColor Cyan
    Write-Host " - Time taken: $($duration.Hours)h $($duration.Minutes)m $($duration.Seconds)s" -ForegroundColor Cyan

    if ($null -ne $updates -and $updates.Count -gt 0) {
        # The Get-WindowsUpdate cmdlet can return multiple objects for a single update (e.g., download, install).
        # We select only the unique updates based on their Title and KBArticleIDs for an accurate count.
        $uniqueUpdates = $updates | Select-Object -Property Title, KBArticleIDs -Unique

        Write-Host " - $($uniqueUpdates.Count) updates were installed:" -ForegroundColor Cyan
        # Format the list of unique updates
        $uniqueUpdates | ForEach-Object {
            $kb = if ($_.KBArticleIDs) { "($($_.KBArticleIDs))" } else { "" }
            Write-Host "   - $($_.Title) $kb"
        }

        # Check the original results to see if any step required a reboot
        $rebootNeeded = $updates | Where-Object { $_.RebootRequired }
        if ($rebootNeeded) {
            Write-Host " - A reboot is required to complete the installation." -ForegroundColor Yellow
            if ($unattended) {
                Write-Host "Unattended mode: A reboot is required. Please reboot manually." -ForegroundColor Yellow
            }
            else {
                $rebootConfirmation = Read-Host "Reboot now? (Y/N)"
                if ($rebootConfirmation -in @('Y', 'y')) {
                    Write-Host "Rebooting in 10 seconds. Press CTRL+C to cancel..."
                    Start-Sleep 10
                    Restart-Computer -Force
                }
            }
        } else {
            Write-Host " - No reboot is required." -ForegroundColor Green
        }
    } else {
        Write-Host " - No updates were found or installed." -ForegroundColor Cyan
    }

}
catch {
    Write-Error "An unexpected error occurred: $_"
}
finally {
    # --- Cleanup ---
    Stop-Transcript
}