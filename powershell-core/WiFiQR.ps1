$data = netsh wlan show interfaces | Select-String SSID
if (!($data)) {
     Write-Host "Not connected to wifi exiting..."
     Start-Start-Sleep -s 5
     exit
} $datePattern = [regex]::new("(?<=SSID                   : ).*\S")
$matches = $datePattern.Matches($data)
$wifiprofile = $matches.Value
$wifiprofile = $wifiprofile.Substring(0, $wifiprofile.IndexOf(' '))
$data2 = netsh wlan show profile $wifiprofile key=clear
$datePattern2 = [regex]::new("(?<=Key Content            : ).*\S")
$matches2 = $datePattern2.Matches($data2)
$wifikey = $matches2.Value.Split(' ')[0]
$wifilink = "WIFI:S:$($wifiprofile);T:WPA;P:$($wifikey);;"
$wifilink = [uri]::EscapeDataString($wifilink)
$URL = "https://chart.googleapis.com/chart?chs=547x547&cht=qr&chld=H|4&choe=UTF-8&chl=$($wifilink)"
Write-Host
Write-Host "SSID: " -ForegroundColor Yellow -NoNewline
Write-Host $wifiprofile
Write-Host "KEY: " -ForegroundColor Yellow -NoNewline
Write-Host $wifikey
Write-Host
Start-Process $URL