# New-DailyRestartTask.ps1
# Creates a new scheduled task to restart your computer daily at a specified time
#
# Function: New-DailyRestartTask
# Follows PowerShell approved verb naming conventions

function New-DailyRestartTask {
    <#
    .SYNOPSIS
    Creates a new scheduled task to restart the computer daily at a specified time.

    .DESCRIPTION
    This function creates a Windows scheduled task that will restart the computer
    daily at a user-specified time. The task runs with SYSTEM privileges and
    provides a 30-second warning before restart.

    .PARAMETER RestartTime
    The time to restart the computer daily (24-hour format, e.g., "03:00" or "15:30")

    .PARAMETER TaskName
    The name for the scheduled task. Defaults to "DailyRestart"

    .EXAMPLE
    New-DailyRestartTask
    Prompts for restart time and creates task with default name

    .EXAMPLE
    New-DailyRestartTask -RestartTime "03:00" -TaskName "NightlyRestart"
    Creates task to restart at 3 AM with custom name
    #>

    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]$RestartTime,

        [Parameter(Position=1)]
        [string]$TaskName = "DailyRestart"
    )

    # Check if running as administrator
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error "This function requires Administrator privileges to create scheduled tasks."
        Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
        return
    }

    Write-Host "=== New-DailyRestartTask ===" -ForegroundColor Cyan
    Write-Host "Creating a scheduled task to restart your computer daily." -ForegroundColor White
    Write-Host ""

    # Get the desired restart time from user if not provided
    if (-not $RestartTime) {
        do {
            $timeInput = Read-Host "Enter the daily restart time (24-hour format, e.g., 03:00 for 3 AM or 15:30 for 3:30 PM)"

            # Try to parse the time
            try {
                $parsedTime = [DateTime]::ParseExact($timeInput, "HH:mm", $null)
                $RestartTime = $timeInput
                $validTime = $true
                Write-Host "Restart time set to: $($parsedTime.ToString('HH:mm'))" -ForegroundColor Green
            }
            catch {
                Write-Host "Invalid time format. Please use HH:MM format (e.g., 03:00 or 15:30)" -ForegroundColor Red
                $validTime = $false
            }
        } while (-not $validTime)
    } else {
        # Validate provided time parameter
        try {
            $parsedTime = [DateTime]::ParseExact($RestartTime, "HH:mm", $null)
            Write-Host "Restart time set to: $($parsedTime.ToString('HH:mm'))" -ForegroundColor Green
        }
        catch {
            Write-Error "Invalid RestartTime parameter. Please use HH:MM format (e.g., 03:00 or 15:30)"
            return
        }
    }

    # Ask for confirmation
    Write-Host ""
    Write-Host "Task Summary:" -ForegroundColor Yellow
    Write-Host "  Task Name: $TaskName" -ForegroundColor White
    Write-Host "  Action: Restart computer" -ForegroundColor White
    Write-Host "  Schedule: Daily at $($parsedTime.ToString('HH:mm'))" -ForegroundColor White
    Write-Host ""

    $confirm = Read-Host "Create this scheduled task? (y/N)"
    if ($confirm -notmatch '^[Yy]') {
        Write-Host "Task creation cancelled." -ForegroundColor Yellow
        return
    }

    try {
        # Create the scheduled task action (restart command)
        $action = New-ScheduledTaskAction -Execute "shutdown.exe" -Argument "/r /f /t 30 /c 'Scheduled daily restart in 30 seconds'"

        # Create the trigger (daily at specified time)
        $trigger = New-ScheduledTaskTrigger -Daily -At $parsedTime

        # Create task settings
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

        # Create the principal (run as SYSTEM with highest privileges)
        $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

        # Register the scheduled task
        Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description "Daily computer restart task created by New-DailyRestartTask function"

        Write-Host ""
        Write-Host "SUCCESS! Scheduled task '$TaskName' has been created." -ForegroundColor Green
        Write-Host "Your computer will restart daily at $($parsedTime.ToString('HH:mm'))" -ForegroundColor Green
        Write-Host ""
        Write-Host "Notes:" -ForegroundColor Yellow
        Write-Host "- The restart will give you a 30-second warning" -ForegroundColor White
        Write-Host "- You can view/modify this task in Task Scheduler (taskschd.msc)" -ForegroundColor White
        Write-Host "- To delete this task later, run: Unregister-ScheduledTask -TaskName '$TaskName' -Confirm:`$false" -ForegroundColor White
    }
    catch {
        Write-Host ""
        Write-Error "Failed to create scheduled task: $($_.Exception.Message)"
        Write-Host ""
        Write-Host "Common fixes:" -ForegroundColor Yellow
        Write-Host "1. Make sure you're running PowerShell as Administrator" -ForegroundColor White
        Write-Host "2. Check if a task with this name already exists" -ForegroundColor White
        Write-Host "3. Verify the time format is correct" -ForegroundColor White
    }
}

# If script is run directly (not dot-sourced), execute the function
if ($MyInvocation.InvocationName -ne '.') {
    Write-Host "Running New-DailyRestartTask..." -ForegroundColor Cyan
    New-DailyRestartTask
    Write-Host ""
    Write-Host "Script execution completed. Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
else {
    Write-Host "New-DailyRestartTask function has been loaded into your session." -ForegroundColor Green
    Write-Host "Usage examples:" -ForegroundColor Yellow
    Write-Host "  New-DailyRestartTask" -ForegroundColor White
    Write-Host "  New-DailyRestartTask -RestartTime '03:00' -TaskName 'NightlyRestart'" -ForegroundColor White
}