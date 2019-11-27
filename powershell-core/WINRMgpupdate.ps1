#############################################
#	Title:      WINRM GPUpdate			    #
#	Creator:	Ad3t0	                    #
#	Date:		06/05/2019             	    #
#############################################
$ver = "1.0.4"
$text1 = @'
     _       _ _____ _    ___
    / \   __| |___ /| |_ / _ \
   / _ \ / _` | |_ \| __| | | |
  / ___ \ (_| |___) | |_| |_| |
 /_/   \_\__,_|____/ \__|\___/
'@
$text2 = '    WINRMGPUpdate'
$text3 = "       Version: "
Write-Host $text1
Write-Host $text2 -ForegroundColor Yellow
Write-Host $text3 -ForegroundColor Gray -NoNewline
Write-Host $ver -ForegroundColor Green
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
