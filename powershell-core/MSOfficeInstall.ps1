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
if (!(Test-Path -Path "C:\Program Files\7-Zip\7z.exe")) {
	$url = "https://www.7-zip.org/a/7z1900-x64.exe"
	$output = "$($env:TEMP)\7z1900-x64.exe"
	Invoke-WebRequest -Uri $url -OutFile $output
	."$($env:TEMP)\7z1900-x64.exe" /S
	Wait-Process -Name 7z1900-x64
}
$url = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_12827-20268.exe"
$output = "$($env:TEMP)\officedeploymenttool_12827-20268.exe"
Invoke-WebRequest -Uri $url -OutFile $output
."C:\Program Files\7-Zip\7z.exe" x "$($env:TEMP)\officedeploymenttool_12827-20268.exe" -o"$($env:TEMP)\officeInstall" -aoa
$configurationO365BusinessRetail = @'
  <Configuration>
	<Add OfficeClientEdition="64" Channel="Current">
	  <Product ID="O365BusinessRetail">
		<Language ID="en-us" />
	  </Product>
	</Add>
  </Configuration>
'@
New-Item "$($env:TEMP)\officeInstall\configuration-O365BusinessRetail-x64.xml" -Force -ErrorAction SilentlyContinue
Set-Content "$($env:TEMP)\officeInstall\configuration-O365BusinessRetail-x64.xml" $configurationO365BusinessRetail -ErrorAction SilentlyContinue
$configurationO365ProPlusRetail = @'
  <Configuration>
	<Add OfficeClientEdition="64" Channel="Current">
	  <Product ID="O365ProPlusRetail">
		<Language ID="en-us" />
	  </Product>
	</Add>
  </Configuration>
'@
New-Item "$($env:TEMP)\officeInstall\configuration-O365ProPlusRetail-x64.xml" -Force -ErrorAction SilentlyContinue
Set-Content "$($env:TEMP)\officeInstall\configuration-O365ProPlusRetail-x64.xml" $configurationO365ProPlusRetail -ErrorAction SilentlyContinue
$configurationProjectProRetail = @'
  <Configuration>
	<Add OfficeClientEdition="64" Channel="Current">
	  <Product ID="ProjectProRetail">
		<Language ID="en-us" />
	  </Product>
	</Add>
  </Configuration>
'@
New-Item "$($env:TEMP)\officeInstall\configuration-ProjectProRetail-x64.xml" -Force -ErrorAction SilentlyContinue
Set-Content "$($env:TEMP)\officeInstall\configuration-ProjectProRetail-x64.xml" $configurationProjectProRetail -ErrorAction SilentlyContinue
$configurationVisioProRetail = @'
  <Configuration>
	<Add OfficeClientEdition="64" Channel="Current">
	  <Product ID="VisioProRetail">
		<Language ID="en-us" />
	  </Product>
	</Add>
  </Configuration>
'@
New-Item "$($env:TEMP)\officeInstall\configuration-VisioProRetail-x64.xml" -Force -ErrorAction SilentlyContinue
Set-Content "$($env:TEMP)\officeInstall\configuration-VisioProRetail-x64.xml" $configurationVisioProRetail -ErrorAction SilentlyContinue
Clear-Host
""
Write-Host "1 - O365 Business Retail"
Write-Host "2 - O365 ProPlus Retail"
Write-Host "3 - Project Pro Retail"
Write-Host "4 - Visio Pro Retail"
""
while ($confirmVersion -ne "1" -and $confirmVersion -ne "2" -and $confirmVersion -ne "3" -and $confirmVersion -ne "4") {
	$confirmVersion = Read-Host "Select Office edition to install. [1/2/3/4]"
}
[Void]$(Hide-PowerShellWindow)
if ($confirmVersion -eq "1") {
	."$($env:TEMP)\officeInstall\setup.exe" /configure "$($env:TEMP)\officeInstall\configuration-O365BusinessRetail-x64.xml"
}
if ($confirmVersion -eq "2") {
	."$($env:TEMP)\officeInstall\setup.exe" /configure "$($env:TEMP)\officeInstall\configuration-O365ProPlusRetail-x64.xml"
}
if ($confirmVersion -eq "3") {
	."$($env:TEMP)\officeInstall\setup.exe" /configure "$($env:TEMP)\officeInstall\configuration-ProjectProRetail-x64.xml"
}
if ($confirmVersion -eq "4") {
	."$($env:TEMP)\officeInstall\setup.exe" /configure "$($env:TEMP)\officeInstall\configuration-VisioProRetail-x64.xml"
}