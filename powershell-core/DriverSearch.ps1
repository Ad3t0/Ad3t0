#############################################
#	Title:      DriverSearch			    #
#	Creator:	Ad3t0	                    #
#	Date:		05/01/2018             	    #
#############################################
$ver = "1.0.7"
$text1 = @'
     _       _ _____ _    ___
    / \   __| |___ /| |_ / _ \
   / _ \ / _` | |_ \| __| | | |
  / ___ \ (_| |___) | |_| |_| |
 /_/   \_\__,_|____/ \__|\___/
'@
$text2 = '     DriverSearch'
$text3 = "        Version: "
Write-Host $text1
Write-Host $text2 -ForegroundColor Yellow
Write-Host $text3 -ForegroundColor Gray -NoNewline
Write-Host $ver -ForegroundColor Green
$systemmodel = wmic computersystem get model /VALUE
$systemmodel = $systemmodel -replace ('Model=','')
$systemmodel = $systemmodel + "drivers"
$systemmodel = [uri]::EscapeDataString($systemmodel)
$systemmodel = $systemmodel -replace ('%20%20%20%20%20%20%20','')
$URL = "https://www.google.com/search?q=$($systemmodel)"
start $URL
