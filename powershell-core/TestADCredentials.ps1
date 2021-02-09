while (!($verifiedCreds)) {
    $username = Read-Host "Enter the username"
    $password = Read-Host "Enter the password"
    $computer = $env:COMPUTERNAME
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    $obj = New-Object System.DirectoryServices.AccountManagement.PrincipalContext ('machine', $computer)
    $goodCreds = $obj.ValidateCredentials($username, $password)
    if ($goodCreds) {
        ""
        Write-Host "Credentials validated successfully" -ForegroundColor Green
        ""
        $verifiedCreds = $true
    }
    else {
        ""
        Write-Warning "Credentials failed to validate"
        ""
    }
}
