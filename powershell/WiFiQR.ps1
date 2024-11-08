# Settings
$qrSize = "547x547"
$qrErrorCorrection = "H"
$qrVersion = "4"

# Get current WiFi connection info
$wifiInterface = netsh wlan show interfaces | Select-String "SSID\s+:"
if (!$wifiInterface) {
    Write-Host "No active WiFi connection detected." -ForegroundColor Red
    exit
}

# Extract SSID using proper regex
$ssid = [regex]::Match($wifiInterface, "(?<=SSID\s+:\s).+").Value.Trim()

# Get WiFi password
$profileInfo = netsh wlan show profile $ssid key=clear
$password = [regex]::Match($profileInfo, "(?<=Key Content\s+:\s).+").Value.Trim()

# Generate WiFi network string
$wifiString = "WIFI:S:$($ssid);T:WPA;P:$($password);;"
$encodedWifiString = [uri]::EscapeDataString($wifiString)

# Create QR code URL
$qrUrl = "https://chart.googleapis.com/chart?cht=qr&chs=$($qrSize)&chld=$($qrErrorCorrection)|$($qrVersion)&choe=UTF-8&chl=$($encodedWifiString)"

# Display network info
Write-Host "`nWiFi Network Details:" -ForegroundColor Cyan
Write-Host "SSID: " -ForegroundColor Yellow -NoNewline
Write-Host $ssid
Write-Host "Password: " -ForegroundColor Yellow -NoNewline
Write-Host $password
Write-Host

# Open QR code in default browser
Start-Process $qrUrl