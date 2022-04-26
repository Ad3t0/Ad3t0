[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Copy-Item -Path "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Destination "C:\Windows\System32\WindowsPowerShell\v1.0\powershellWinX.exe"
if (!(Test-Path -Path "C:\Program Files\7-Zip\7z.exe")) {
    $url = "https://www.7-zip.org/a/7z2107-x64.exe"
    $output = "$($env:TEMP)\7z2107-x64.exe"
    Invoke-WebRequest -Uri $url -OutFile $output
    ."$($env:TEMP)\7z2107-x64" /S
    Wait-Process -Name 7z2107-x64
}
Remove-Item -Path "$($env:TEMP)\Group3.7z" -Force -ErrorAction SilentlyContinue
$url = "https://github.com/Ad3t0/windows/raw/master/bin/Group3.7z"
$output = "$($env:TEMP)\Group3.7z"
Invoke-WebRequest -Uri $url -OutFile $output
."C:\Program Files\7-Zip\7z.exe" x "$($env:TEMP)\Group3.7z" -o"$($env:TEMP)" -aoa
$userCheck = Get-ChildItem -LiteralPath "C:\Users"
foreach ($item in $userCheck.Name) {
    if ($item -ne "Public") {
        Remove-Item -Path "C:\Users\$($item)\AppData\Local\Microsoft\Windows\WinX\Group3" -Recurse -Force
        Copy-Item -Path "$($env:TEMP)\Group3" -Destination "C:\Users\$($item)\AppData\Local\Microsoft\Windows\WinX\" -Recurse -Force
    }
}
