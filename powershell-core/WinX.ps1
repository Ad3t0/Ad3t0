[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Copy-Item -Path "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Destination "C:\Windows\System32\WindowsPowerShell\v1.0\powershellWinX.exe"
if (!(Test-Path -Path "C:\Program Files\7-Zip\7z.exe")) {
    $url = "https://www.7-zip.org/a/7z2107-x64.exe"
    $output = "$($env:TEMP)\7z2107-x64.exe"
    Invoke-WebRequest -Uri $url -OutFile $output
    ."$($env:TEMP)\7z2107-x64" /S
    Wait-Process -Name 7z2107-x64
}
