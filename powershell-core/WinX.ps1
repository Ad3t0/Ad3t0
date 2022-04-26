
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Copy-Item -Path "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Destination "C:\Windows\System32\WindowsPowerShell\v1.0\powershellWinX.exe"
if (!(Test-Path -Path "C:\Program Files\7-Zip\7z.exe")) {
    $url = "https://www.7-zip.org/a/7z2107-x64.exe"
    $output = "$($env:TEMP)\7z2107-x64.exe"
    Invoke-WebRequest -Uri $url -OutFile $output
    ."$($env:TEMP)\7z2107-x64" /S
    Wait-Process -Name 7z2107-x64
}
$url = "https://github.com/Beej126/WinXMenuPwsh/archive/refs/heads/main.zip"
$output = "$($env:TEMP)\main.zip"
Invoke-WebRequest -Uri $url -OutFile $output
."C:\Program Files\7-Zip\7z.exe" x "$($env:TEMP)\main.zip" -o"$($env:TEMP)\WinX" -aoa
$favesFile = @"
Display Name               | Target                                                        | Working Dir           | Elevated | Arguments
-------------------------- | ------------------------------------------------------------- | --------------------- | -------- | ----------------------------------------------
Uninstall Programs         | %windir%\explorer.exe                                         |                       |          | shell:::{7b81be6a-ce2b-4676-a29e-eb907a5126c5}
Services                   | %windir%\System32\services.msc                                |                       | True     |
System Domain Menu         | %windir%\System32\rundll32.exe                                |                       |          | shell32.dll,Control_RunDLL sysdm.cpl
Sound Control Panel        | %windir%\System32\rundll32.exe                                |                       |          | shell32.dll,Control_RunDLL mmsys.cpl
Network Adapters           | %windir%\explorer.exe                                         |                       |          | shell:::{7007ACC7-3202-11D1-AAD2-00805FC1270E}
Task Scheduler             | %windir%\System32\taskschd.msc                                |                       |          | /s
Event Viewer               | %windir%\System32\eventvwr.exe                                |                       |          |
System                     | %windir%\explorer.exe                                         |                       |          | shell:::{BB06C0E4-D293-4f75-8A90-CB05B6477EEE}
Device Manager             | %windir%\System32\devmgmt.msc                                 |                       |          |
Disk Management            | %windir%\System32\diskmgmt.msc                                |                       | True     |
Computer Management        | %windir%\System32\compmgmt.msc                                |                       |          |
Windows PowerShell         | %windir%\System32\WindowsPowerShell\v1.0\powershellWinX.exe   | %HOMEDRIVE%%HOMEPATH% |          |
Windows PowerShell (Admin) | %windir%\System32\WindowsPowerShell\v1.0\powershellWinX.exe   |                       | True     |
"@
Set-Content "$($env:TEMP)\WinX\WinXMenuPwsh-main\faves.md" $favesFile
Set-Location -Path "$($env:TEMP)\WinX\WinXMenuPwsh-main"
$ps1Edit = Get-Content "$($env:TEMP)\WinX\WinXMenuPwsh-main\regenFromFaves.ps1"
$ps1Edit = $ps1Edit -replace "pause", ""
$ps1Edit = $ps1Edit -replace "kill -Name explorer \| wait-process", ""
$ps1Edit = $ps1Edit -replace "explorer \`$PSScriptRoot", ""
Set-Content "$($env:TEMP)\WinX\WinXMenuPwsh-main\regenFromFaves.ps1" $ps1Edit
."$($env:TEMP)\WinX\WinXMenuPwsh-main\regenFromFaves.ps1"
Start-Sleep 5
$userCheck = Get-ChildItem -LiteralPath "C:\Users"
foreach ($item in $userCheck.Name) {
    if ($item -ne "Public" -and $item -ne "Default") {
        Remove-Item -Path "C:\Users\$($item)\AppData\Local\Microsoft\Windows\WinX\Group3" -Recurse -Force
        Copy-Item -Path "C:\Users\Default\AppData\Local\Microsoft\Windows\WinX\Group3" -Destination "C:\Users\$($item)\AppData\Local\Microsoft\Windows\WinX\" -Recurse -Force
    }
}
