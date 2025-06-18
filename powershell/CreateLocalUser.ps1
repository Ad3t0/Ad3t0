#Requires -RunAsAdministrator

# Function to generate a random password using an API
function Generate-StrongPassword {
    # Pick a word length (6-8), pull one English word of that length,
    # capitalise it, and glue on four random digits.
    try {
        $len  = Get-Random -Minimum 6 -Maximum 9 # 6,7,8
        $word = (Invoke-RestMethod "https://random-word-api.herokuapp.com/word?number=1&length=$len")[0]
        $word = $word.Substring(0,1).ToUpper() + $word.Substring(1)
        $pass = "$word$(Get-Random -Minimum 1000 -Maximum 10000)"
        return $pass
    }
    catch {
        Write-Host "Failed to generate password from API. Error: $_" -ForegroundColor Red
        Write-Host "Please enter a password manually." -ForegroundColor Yellow
        return $null
    }
}

# --- Script Start ---

# Prompt for the username
$username = Read-Host -Prompt "Enter the username for the new local user"

# Check if user already exists to prevent errors
if (Get-LocalUser -Name $username -ErrorAction SilentlyContinue) {
    Write-Host "User '$username' already exists. Exiting script." -ForegroundColor Red
    exit
}

# Prompt for password generation or manual entry
$choice = Read-Host -Prompt "Do you want to (G)enerate a password or (M)anually enter one? [G/M]"
$password = $null

if ($choice -match '^[Gg]$') {
    $generatedPassword = Generate-StrongPassword
    if ($generatedPassword) {
        Write-Host "Generated Password: $generatedPassword" -ForegroundColor Green
        $password = ConvertTo-SecureString $generatedPassword -AsPlainText -Force
    }
    else {
        # API failed, force manual entry
        $password = Read-Host -Prompt "Enter the password for $username" -AsSecureString
    }
}
elseif ($choice -match '^[Mm]$') {
    $password = Read-Host -Prompt "Enter the password for $username" -AsSecureString
}
else {
    Write-Host "Invalid choice. Exiting script." -ForegroundColor Red
    exit
}

# Create the new local user
try {
    New-LocalUser -Name $username -Password $password -FullName $username -Description "Created by script" -PasswordNeverExpires:$false
    Write-Host "User '$username' created successfully." -ForegroundColor Green
}
catch {
    Write-Host "Failed to create user '$username'. Error: $_" -ForegroundColor Red
    exit
}

# Prompt to add to Administrators group
$adminChoice = Read-Host -Prompt "Add '$username' to the local Administrators group? [Y/N]"
if ($adminChoice -match '^[Yy]$') {
    try {
        Add-LocalGroupMember -Group "Administrators" -Member $username
        Write-Host "'$username' has been added to the Administrators group." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to add user to Administrators group. Error: $_" -ForegroundColor Red
    }
}
else {
    try {
        Add-LocalGroupMember -Group "Users" -Member $username
        Write-Host "'$username' has been added to the Users group." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to add user to Users group. Error: $_" -ForegroundColor Red
    }
}

# Prompt to add to Remote Desktop Users group
$rdpChoice = Read-Host -Prompt "Add '$username' to the Remote Desktop Users group? [Y/N]"
if ($rdpChoice -match '^[Yy]$') {
    try {
        Add-LocalGroupMember -Group "Remote Desktop Users" -Member $username
        Write-Host "'$username' has been added to the Remote Desktop Users group." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to add user to Remote Desktop Users group. Error: $_" -ForegroundColor Red
    }
}

Write-Host "Script finished."