$ver = "1.1.6"
$modPathRemoteScript = Read-Host "Enter the path of the script"
$adComputers = Get-ADComputer -Filter { OperatingSystem -NotLike "Windows Server*" } | Select-Object -ExpandProperty Name
$adComputersTested = { $adComputersTested }.Invoke()
$adComputersTested.Clear()
foreach ($computer in $adComputers) {
     if (Test-Connection $computer -Quiet -Count 1) {
          $adComputersTested.Add($computer)
     }
} $adComputersTested
$adComputersTested | ForEach-Object { Write-Host $_ ; Invoke-Command -ComputerName $_ -FilePath $modPathRemoteScript }
Write-Host
Write-Host "Complete!" -ForegroundColor green
Read-Host "Press ENTER to exit"
