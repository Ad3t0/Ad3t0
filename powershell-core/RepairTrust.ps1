$username = Read-Host "Enter the username for renaming"
$password = Read-Host "Enter the domain user password for renaming"
$encrypted = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PsCredential($username, $encrypted)
Test-ComputerSecureChannel -Repair -Credential $credential
