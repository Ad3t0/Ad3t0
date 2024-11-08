# Get system model and format for URL
$systemModel = (Get-WmiObject -Class Win32_ComputerSystem).Model
$searchQuery = "$($systemModel) drivers"
$encodedQuery = [uri]::EscapeDataString($searchQuery.Trim())

# Construct and open Google search URL
$googleUrl = "https://www.google.com/search?q=$($encodedQuery)"
Start-Process $googleUrl