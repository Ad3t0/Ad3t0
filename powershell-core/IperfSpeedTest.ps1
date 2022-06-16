if (!(Test-Path -Path "C:\Program Files\7-Zip\7z.exe")) {
    $url = "https://www.7-zip.org/a/7z2107-x64.exe"
    $output = "$($env:TEMP)\7z2107-x64.exe"
    Invoke-WebRequest -Uri $url -OutFile $output
    ."$($env:TEMP)\7z2107-x64" /S
    Wait-Process -Name 7z2107-x64
}
if (!(Test-Path -Path "$($env:TEMP)\iperf-3.1.3-win64\iperf3.exe")) {
    $url = "https://iperf.fr/download/windows/iperf-3.1.3-win64.zip"
    $output = "$($env:TEMP)\iperf-3.1.3-win64.zip"
    Invoke-WebRequest -Uri $url -OutFile $output
    ."C:\Program Files\7-Zip\7z.exe" x "$($env:TEMP)\iperf-3.1.3-win64.zip" -o"$($env:TEMP)\" -aoa
}
Clear-Host
""
Write-Host "1 - Client"
Write-Host "2 - Server"
""
while ($confirmVersion -ne "1" -and $confirmVersion -ne "2") {
    $confirmVersion = Read-Host "Select iperf mode [1/2]"
}
if ($confirmVersion -eq "1") {
    $ipAddress = Read-Host "Enter iperf3 server IP address"
    Write-Host "Running iperf3 client..."
    ."$($env:TEMP)\iperf-3.1.3-win64\iperf3.exe" -c $ipAddress -t 30
}
if ($confirmVersion -eq "2") {
    Write-Host "Running iperf3 server..."
    ."$($env:TEMP)\iperf-3.1.3-win64\iperf3.exe" -s
}
