$ver = "1.0.4"
$adComputers = Get-ADComputer -Filter { OperatingSystem -NotLike "Windows Server*" } | Select-Object -ExpandProperty Name
$adComputersTested = { $adComputersTested }.Invoke()
$adComputersTested.Clear()
foreach ($computer in $adComputers) {
     if (Test-Connection $computer -Quiet -Count 1) {
          $adComputersTested.Add($computer)
     }
} 
$adComputersTested | ForEach-Object { Write-Host $_ ; Invoke-Command -ComputerName $_ -ScriptBlock { gpupdate /force } }
Write-Host
Write-Host "Complete!" -ForegroundColor green
Read-Host "Press ENTER to exit"
