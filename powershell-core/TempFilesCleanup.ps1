$disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object FreeSpace
$freeSpace = $disk.FreeSpace / 1GB
$freeSpace = [math]::Round($freeSpace, 2)
""
Write-Host "Current free space on C: = $($freeSpace)GB" -ForegroundColor Yellow
""
$folders = @('C:\Windows\Temp\*', 'C:\Documents and Settings\*\Local Settings\temp\*', 'C:\Users\*\Appdata\Local\Temp\*', 'C:\Users\*\Appdata\Local\Microsoft\Windows\Temporary Internet Files\*', 'C:\Windows\SoftwareDistribution\Download', 'C:\Windows\System32\FNTCACHE.DAT')
$folders
while ($fileTempConf -ne "n" -and $fileTempConf -ne "y") {
    ""
    $fileTempConf = Read-Host "Clean all temporary system file from listed directories? [y/n]"
}
if ($fileTempConf -eq "y") {
    foreach ($folder in $folders) {
        ""
        Write-Host "Removing files in $($folder)" -ForegroundColor Yellow
        ""
        Remove-Item $folder -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "Finished removing files in $($folder)" -ForegroundColor Yellow
    }
    ""
    Write-Host "Finished removing all temp files." -ForegroundColor Green
    $disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object FreeSpace
    $freeSpace = $disk.FreeSpace / 1GB
    $freeSpace = [math]::Round($freeSpace, 2)
    ""
    Write-Host "Free space after cleaning temp files on C: = $($freeSpace)GB" -ForegroundColor Green
    ""
}