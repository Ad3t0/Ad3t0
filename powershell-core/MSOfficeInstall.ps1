Function Hide-PowerShellWindow() {
	[CmdletBinding()]
	param (
		[IntPtr]$Handle = $(Get-Process -id $PID).MainWindowHandle
	)
	$WindowDisplay = @"
	using System;
	using System.Runtime.InteropServices;
	namespace Window
	{
		public class Display
		{
			[DllImport("user32.dll")]
			private static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
			public static bool Hide(IntPtr hWnd)
			{
				return ShowWindowAsync(hWnd, 0);
			}
		}
	}
"@
	Try {
		Add-Type -TypeDefinition $WindowDisplay
		[Window.Display]::Hide($Handle)
	}
	Catch {
	}
}
Install-Script -Name Install-Office365Suite -Confirm:$False -Force
$configurationO365BusinessRetail = @'
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
'@
New-Item "$($env:TEMP)\officeInstall\configuration-O365BusinessRetail-x64.xml" -Force -ErrorAction SilentlyContinue
Set-Content "$($env:TEMP)\officeInstall\configuration-O365BusinessRetail-x64.xml" $configurationO365BusinessRetail -ErrorAction SilentlyContinue
$configurationO365ProPlusRetail = @'
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
'@
New-Item "$($env:TEMP)\officeInstall\configuration-O365ProPlusRetail-x64.xml" -Force -ErrorAction SilentlyContinue
Set-Content "$($env:TEMP)\officeInstall\configuration-O365ProPlusRetail-x64.xml" $configurationO365ProPlusRetail -ErrorAction SilentlyContinue
$configurationProjectProRetail = @'
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
'@
New-Item "$($env:TEMP)\officeInstall\configuration-ProjectProRetail-x64.xml" -Force -ErrorAction SilentlyContinue
Set-Content "$($env:TEMP)\officeInstall\configuration-ProjectProRetail-x64.xml" $configurationProjectProRetail -ErrorAction SilentlyContinue
$configurationVisioProRetail = @'
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
'@
New-Item "$($env:TEMP)\officeInstall\configuration-VisioProRetail-x64.xml" -Force -ErrorAction SilentlyContinue
Set-Content "$($env:TEMP)\officeInstall\configuration-VisioProRetail-x64.xml" $configurationVisioProRetail -ErrorAction SilentlyContinue
$configurationUninstall = @'
<Configuration>
    <Remove All="TRUE">
        <Product ID="O365BusinessRetail">
            <Language ID="en-us" />
        </Product>
    </Remove>
    <Display Level="None" AcceptEULA="TRUE" />
</Configuration>
'@
New-Item "$($env:TEMP)\officeInstall\configuration-Uninstall.xml" -Force -ErrorAction SilentlyContinue
Set-Content "$($env:TEMP)\officeInstall\configuration-Uninstall.xml" $configurationUninstall -ErrorAction SilentlyContinue
Clear-Host
""
Write-Host "1 - O365 Business Retail"
Write-Host "2 - O365 ProPlus Retail"
Write-Host "3 - Project Pro Retail"
Write-Host "4 - Visio Pro Retail"
Write-Host "5 - Uninstall"
""
while ($confirmVersion -ne "1" -and $confirmVersion -ne "2" -and $confirmVersion -ne "3" -and $confirmVersion -ne "4" -and $confirmVersion -ne "5") {
	$confirmVersion = Read-Host "Select Office edition to install. [1/2/3/4/5]"
}
[Void]$(Hide-PowerShellWindow)
if ($confirmVersion -eq "1") {
	."$env:ProgramFiles\WindowsPowerShell\Scripts\Install-Office365Suite.ps1" -ConfigurationXMLFile "$($env:TEMP)\officeInstall\configuration-O365BusinessRetail-x64.xml" -CleanUpInstallFiles
}
if ($confirmVersion -eq "2") {
	."$env:ProgramFiles\WindowsPowerShell\Scripts\Install-Office365Suite.ps1" -ConfigurationXMLFile "$($env:TEMP)\officeInstall\configuration-O365ProPlusRetail-x64.xml" -CleanUpInstallFiles
}
if ($confirmVersion -eq "3") {
	."$env:ProgramFiles\WindowsPowerShell\Scripts\Install-Office365Suite.ps1" -ConfigurationXMLFile "$($env:TEMP)\officeInstall\configuration-ProjectProRetail-x64.xml" -CleanUpInstallFiles
}
if ($confirmVersion -eq "4") {
	."$env:ProgramFiles\WindowsPowerShell\Scripts\Install-Office365Suite.ps1" -ConfigurationXMLFile "$($env:TEMP)\officeInstall\configuration-VisioProRetail-x64.xml" -CleanUpInstallFiles
}
if ($confirmVersion -eq "5") {
	."$env:ProgramFiles\WindowsPowerShell\Scripts\Install-Office365Suite.ps1" -ConfigurationXMLFile "$($env:TEMP)\officeInstall\configuration-Uninstall.xml" -CleanUpInstallFiles
}