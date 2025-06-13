# Ask for confirmation before running the script
$confirmation = Read-Host "This script will customize Windows 11 settings and unpin apps from the taskbar. Are you sure you want to continue? (y/n)"
if ($confirmation -ne 'y') {
    Write-Host "Operation cancelled by the user."
    exit
}

Write-Host "Starting Windows 11 customization script..."

# Define paths and application list
$advPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$searchPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search'
$personalPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
$appsToRemove = @("Microsoft Edge", "Microsoft Store", "Mail", "Copilot", "Microsoft 365 (Office)", "Outlook (new)", "Outlook")

# Apply Taskbar and UI customizations
Write-Host "Applying Taskbar and UI customizations..."
New-ItemProperty -Path $advPath -Name TaskbarDa -Value 0 -PropertyType DWord -Force # Widgets
Write-Host "- Disabled Widgets icon."
New-ItemProperty -Path $advPath -Name TaskbarMn -Value 0 -PropertyType DWord -Force # Teams Chat
Write-Host "- Disabled Teams Chat icon."
New-ItemProperty -Path $advPath -Name ShowTaskViewButton -Value 0 -PropertyType DWord -Force # Task View
Write-Host "- Disabled Task View button."
New-ItemProperty -Path $advPath -Name ShowCopilotButton -Value 0 -PropertyType DWord -Force # Copilot
Write-Host "- Disabled Copilot button."
New-ItemProperty -Path $searchPath -Name SearchboxTaskbarMode -Value 0 -PropertyType DWord -Force # Search box
Write-Host "- Set search box to icon only."
New-ItemProperty -Path $advPath -Name FeedEnabled -Value 0 -PropertyType DWord -Force # News feed
Write-Host "- Disabled news and interests feed."
New-ItemProperty -Path $advPath -Name TaskbarAl -Value 0 -PropertyType DWord -Force # Start on left
Write-Host "- Aligned Taskbar to the left."
New-ItemProperty -Path $personalPath -Name AppsUseLightTheme -Value 0 -PropertyType DWord -Force # Dark Theme Apps
Write-Host "- Enabled Dark Theme for applications."
New-ItemProperty -Path $personalPath -Name SystemUsesLightTheme -Value 0 -PropertyType DWord -Force # Dark Theme System
Write-Host "- Enabled Dark Theme for the system."

# Unpin applications from the Taskbar
Write-Host "Unpinning applications from the Taskbar..."
foreach ($app in $appsToRemove) {
    Write-Host "- Attempting to unpin '$app'..."
    $item = ((New-Object -Com Shell.Application).Namespace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | Where-Object { $_.Name -eq $app })
    if ($item) {
        $verb = $item.Verbs() | Where-Object { $_.Name.Replace('&', '') -match 'Unpin from taskbar' }
        if ($verb) {
            $verb.DoIt()
            Write-Host "  - Successfully unpinned '$app'."
        } else {
            Write-Host "  - 'Unpin from taskbar' action not found for '$app'."
        }
    } else {
        Write-Host "  - Application '$app' not found."
    }
}

# Set the desktop wallpaper
Write-Host "Setting desktop wallpaper..."
$wall = "$env:SystemRoot\Web\4K\Wallpaper\Windows\img19_1920x1200.jpg"

Add-Type '
  using System;
  using System.Runtime.InteropServices;
  public class Native {
      [DllImport("user32.dll", SetLastError=true)]
      public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
  }
'

[Native]::SystemParametersInfo(0x0014, 0, $wall, 0x03) | Out-Null
Write-Host "- Wallpaper set to the default dark theme Windows 11 wallpaper."

# Disable OneDrive
Write-Host "Disabling OneDrive..."
$runKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
Remove-ItemProperty -Path $runKey -Name 'OneDrive' -ErrorAction SilentlyContinue
Write-Host "- Removed OneDrive from startup."
Get-Process OneDrive -ErrorAction SilentlyContinue | Stop-Process -Force
Write-Host "- Stopped the OneDrive process."

# The original script had a second unpin loop. It is preserved here for consistency.
Write-Host "Running second pass to unpin applications from the Taskbar..."
foreach ($app in $appsToRemove) {
    Write-Host "- Attempting to unpin '$app'..."
    $item = ((New-Object -Com Shell.Application).Namespace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | Where-Object { $_.Name -eq $app })
    if ($item) {
        $verb = $item.Verbs() | Where-Object { $_.Name.Replace('&', '') -match 'Unpin from taskbar' }
        if ($verb) {
            $verb.DoIt()
            Write-Host "  - Successfully unpinned '$app'."
        } else {
            Write-Host "  - 'Unpin from taskbar' action not found for '$app'."
        }
    } else {
        Write-Host "  - Application '$app' not found."
    }
}

Write-Host "Customization script finished successfully."
