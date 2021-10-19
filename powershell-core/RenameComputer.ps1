while (!($verifiedCreds)) {
    $username = Read-Host "Enter the domain username for renaming"
    $password = Read-Host "Enter the domain user password for renaming"
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    $obj = New-Object System.DirectoryServices.AccountManagement.PrincipalContext ('machine', $computer)
    $goodCreds = $obj.ValidateCredentials($username, $password)
    if ($goodCreds) {
        ""
        Write-Host "Credentials validated successfully" -ForegroundColor Green
        ""
        while ($newPCName -ne $True) {
            $newPCName = Read-Host "Enter the new computer name"
            if ($newPCName -match "^(?!\.)(?![0-9]{1,15}$)[a-zA-Z0-9-_.]{1,15}$") {
                $newPCName = $True
            }
            else {
                Write-Warning "The new computer name was invalid"
                ""
            }
        }
        $encrypted = ConvertTo-SecureString $password -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PsCredential($username, $encrypted)
        if ($env:USERDOMAIN) {
            Rename-Computer -NewName $newPCName -DomainCredential $credential
        }
        else {
            Rename-Computer -NewName $newPCName -LocalCredential $credential
        }
        $verifiedCreds = $true
    }
    else {
        ""
        Write-Warning "Credentials failed to validate"
        ""
    }
}
