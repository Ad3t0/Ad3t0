$systemmodel = wmic computersystem get model /VALUE
$systemmodel = $systemmodel -replace ('Model=', '')
$systemmodel = $systemmodel + "drivers"
$systemmodel = [uri]::EscapeDataString($systemmodel)
$systemmodel = $systemmodel -replace ('%20%20%20%20%20%20%20', '')
$URL = "https://www.google.com/search?q=$($systemmodel)"
Start-Process $URL
