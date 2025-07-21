# Settings
$installPath = "C:\Windows\Temp\OfficeInstall"
$downloadPageURL = "https://www.microsoft.com/en-us/download/details.aspx?id=49117" # The Microsoft Download Center page
$officeDeploymentToolExe = "$installPath\officedeploymenttool.exe"
$setupExe = "$installPath\setup.exe"

# XML Configurations - Updated with SourcePath
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
  <SourcePath  SourcePath = "$installPath" />
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
  <SourcePath  SourcePath = "$installPath" />
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
  <SourcePath  SourcePath = "$installPath" />
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
  <SourcePath  SourcePath = "$installPath" />
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
    <Remove All="TRUE" />
    <Display Level="None" AcceptEULA="TRUE" />
</Configuration>
"@
    }
}

# Create install directory
New-Item -Path $installPath -ItemType Directory -Force | Out-Null

# Dynamically get the Office Deployment Tool URL
try {
    $webClient = New-Object System.Net.WebClient
    # Get the content from the Office Deployment Tool download page
    $downloadPageContent = $webClient.DownloadString($downloadPageURL)
    # Use a RegEx to extract the link. This is the part that might break in the future
    $officeDeploymentToolURL = [regex]::Matches($downloadPageContent, 'href="([^"]*officedeploymenttool.*?\.exe)"') | ForEach-Object {$_.Groups[1].Value} | Select-Object -First 1
    if (-not $officeDeploymentToolURL) {
        throw "Could not find the Office Deployment Tool download URL on the page."
    }
    Write-Host "Successfully retrieved the Office Deployment Tool URL: $($officeDeploymentToolURL)"
}
catch {
    Write-Error "Failed to retrieve the Office Deployment Tool URL dynamically. Please check your internet connection and the Microsoft download page."
    Write-Error "Error: $($_.Exception.Message)"
    exit 1
}

# Download Office Deployment Tool - with TLS 1.2 support
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($officeDeploymentToolURL, $officeDeploymentToolExe)
    Write-Host "Successfully downloaded the Office Deployment Tool."
}
catch {
    Write-Error "Failed to download the Office Deployment Tool. Please check your internet connection, TLS settings, and ensure you have the necessary permissions."
    Write-Error "Error: $($_.Exception.Message)"
    exit 1
}

# Extract the Office Deployment Tool silently
try {
    & "$officeDeploymentToolExe" /extract:"$installPath" /quiet > $null
    Write-Host "Successfully extracted the Office Deployment Tool silently."
}
catch {
    Write-Error "Failed to extract the Office Deployment Tool. Please check that the download was successful."
    Write-Error "Error: $($_.Exception.Message)"
    exit 1
}

# Create XML files
foreach ($config in $configurations.Keys) {
    $xmlPath = "$installPath\configuration-$($config).xml"
    Set-Content -Path $xmlPath -Value $($configurations[$config].XML) -Force
}

# Display menu - in numerical order
Clear-Host
$configurations.Keys | Sort-Object { $configurations[$_].Number } | ForEach-Object {
    Write-Host "$($configurations[$_].Number) - $($configurations[$_].Name)"
}
""

# Get user selection
do {
    $selection = Read-Host "Select Office edition to install [1-5]"
} while ($selection -notmatch '^[1-5]$')

# Install selected configuration
$selectedConfig = $configurations.Keys | Where-Object { $($configurations[$_].Number) -eq $selection }
$configPath = "$installPath\configuration-$($selectedConfig).xml"

# Run Setup.exe with Configuration
Write-Host "Running setup.exe to install (or uninstall) Office..."
try {
    & "$setupExe" /configure "$configPath"
    Write-Host "Office installation (or uninstallation) completed successfully."
}
catch {
    Write-Error "Failed to install (or uninstall) Office."
    Write-Error "Error: $($_.Exception.Message)"
    exit 1
}
