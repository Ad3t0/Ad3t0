# Settings
$installPath = "C:\Windows\Temp\OfficeInstall"
$scriptName = "Install-Office365Suite"

# XML Configurations
$configurations = @{
    "O365BusinessRetail" = @{
        Number = "1"
        Name = "O365 Business Retail"
        XML = @"
<Configuration>
  <Add OfficeClientEdition="64" Channel="Current">
    <Product ID="O365BusinessRetail">
      <Language ID="MatchOS" />
    </Product>
  </Add>
  <Property Name="PinIconsToTaskbar" Value="FALSE" />
  <Property Name="SharedComputerLicensing" Value="0" />
  <Display Level="Full" AcceptEULA="TRUE" />
  <Updates Enabled="TRUE" />
  <RemoveMSI />
</Configuration>
"@
    }
    "O365ProPlusRetail" = @{
        Number = "2"
        Name = "O365 ProPlus Retail"
        XML = @"
<Configuration>
  <Add OfficeClientEdition="64" Channel="Current">
    <Product ID="O365ProPlusRetail">
      <Language ID="MatchOS" />
    </Product>
  </Add>
  <Property Name="PinIconsToTaskbar" Value="FALSE" />
  <Property Name="SharedComputerLicensing" Value="0" />
  <Display Level="Full" AcceptEULA="TRUE" />
  <Updates Enabled="TRUE" />
  <RemoveMSI />
</Configuration>
"@
    }
    "ProjectProRetail" = @{
        Number = "3"
        Name = "Project Pro Retail"
        XML = @"
<Configuration>
  <Add OfficeClientEdition="64" Channel="Current">
    <Product ID="ProjectProRetail">
      <Language ID="MatchOS" />
    </Product>
  </Add>
  <Property Name="PinIconsToTaskbar" Value="FALSE" />
  <Property Name="SharedComputerLicensing" Value="0" />
  <Display Level="Full" AcceptEULA="TRUE" />
  <Updates Enabled="TRUE" />
  <RemoveMSI />
</Configuration>
"@
    }
    "VisioProRetail" = @{
        Number = "4"
        Name = "Visio Pro Retail"
        XML = @"
<Configuration>
  <Add OfficeClientEdition="64" Channel="Current">
    <Product ID="VisioProRetail">
      <Language ID="MatchOS" />
    </Product>
  </Add>
  <Property Name="PinIconsToTaskbar" Value="FALSE" />
  <Property Name="SharedComputerLicensing" Value="0" />
  <Display Level="Full" AcceptEULA="TRUE" />
  <Updates Enabled="TRUE" />
  <RemoveMSI />
</Configuration>
"@
    }
    "Uninstall" = @{
        Number = "5"
        Name = "Uninstall Office"
        XML = @"
<Configuration>
    <Remove All="TRUE">
        <Product ID="O365BusinessRetail">
            <Language ID="en-us" />
        </Product>
    </Remove>
    <Display Level="None" AcceptEULA="TRUE" />
</Configuration>
"@
    }
}

# Create install directory
New-Item -Path $installPath -ItemType Directory -Force | Out-Null

# Install required script
Install-Script -Name $scriptName -Confirm:$false -Force

# Create XML files
foreach ($config in $configurations.GetEnumerator()) {
    $xmlPath = "$installPath\configuration-$($config.Key).xml"
    Set-Content -Path $xmlPath -Value $config.Value.XML -Force
}

# Display menu
Clear-Host
""
foreach ($config in $configurations.GetEnumerator()) {
    Write-Host "$($config.Value.Number) - $($config.Value.Name)"
}
""

# Get user selection
do {
    $selection = Read-Host "Select Office edition to install [1-5]"
} while ($selection -notmatch '^[1-5]$')

# Hide PowerShell window
$WindowCode = @"
using System;
using System.Runtime.InteropServices;
namespace Window {
    public class Display {
        [DllImport("user32.dll")]
        private static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
        public static bool Hide(IntPtr hWnd) { return ShowWindowAsync(hWnd, 0); }
    }
}
"@
Add-Type -TypeDefinition $WindowCode
[Window.Display]::Hide((Get-Process -Id $PID).MainWindowHandle)

# Install selected configuration
$selectedConfig = $configurations.GetEnumerator() | Where-Object { $_.Value.Number -eq $selection } | Select-Object -First 1
$configPath = "$installPath\configuration-$($selectedConfig.Key).xml"
& "$env:ProgramFiles\WindowsPowerShell\Scripts\$scriptName.ps1" -ConfigurationXMLFile $configPath -CleanUpInstallFiles