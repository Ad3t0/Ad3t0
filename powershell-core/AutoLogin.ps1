while (!($verifiedCreds)) {
    $currentUsername = (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -ErrorAction SilentlyContinue).GetValue('DefaultUserName')
    $currentDomainName = (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -ErrorAction SilentlyContinue).GetValue('DefaultDomainName')
    $currentPassword = (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -ErrorAction SilentlyContinue).GetValue('DefaultPassword')
    if ($currentUsername -or $currentDomainName -or $currentPassword) {
        Write-Host "Current auto-login settings are displayed below"
        Write-Host ""
        Write-Host "Username: $($currentUsername)"
        Write-Host "Domain Name: $($currentDomainName)"
        Write-Host "Password: $($currentPassword)"
        Write-Host ""
        Write-Host "Enter auto login credentials, for domain user format like domain\username. Press enter and leave blank to clear"
    }
    else {
        Write-Host "Enter auto login credentials, for domain user format like domain\username."
    }
    Write-Host ""
    $username = Read-Host "Enter the autologin username"
    if ($null -eq $username -or $username -eq "") {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultDomainName" -Value ""
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -Value ""
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -Value ""
        $verifiedCreds = $true
        Write-Warning "Username entry was empty so auto login settings have been cleared"
    }
    else {
        $password = Read-Host "Enter the autologin password"
        $computer = $env:COMPUTERNAME
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
        $obj = New-Object System.DirectoryServices.AccountManagement.PrincipalContext ('machine', $computer)
        $goodCreds = $obj.ValidateCredentials($username, $password)
        if ($goodCreds) {
            $username = $username -split "\\"
            if ($username.Count -eq 2) {
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultDomainName" -Value $username[0]
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -Value $username[1]
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -Value $password
            }
            else {
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -Value $username
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -Value $password
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Value 1
            $verifiedCreds = $true
            ""
            Write-Host "Credentials validated successfully, auto-login has been configured" -ForegroundColor Green
            ""
        }
        else {
            ""
            Write-Warning "Credentials failed to validate please try again"
            ""
        }
    }
}
$verifiedCreds = $false