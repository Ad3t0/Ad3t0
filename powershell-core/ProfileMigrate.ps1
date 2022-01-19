$edition = Get-ComputerInfo | Select-Object WindowsProductName
if ($edition.WindowsProductName -like "*Pro*") {
	$computer = $env:COMPUTERNAME
	$users = C:\Windows\System32\query.exe user /server:$computer 2>&1
	$users = $users | ForEach-Object {
    (($_.trim() -replace ">" -replace "(?m)^([A-Za-z0-9]{3,})\s+(\d{1,2}\s+\w+)", '$1  none  $2' -replace "\s{2,}", "," -replace "none", $null))
	} | ConvertFrom-Csv
	foreach ($user in $users) {
		if ($user.STATE -eq "Active") {
			$currentUser = $user.USERNAME
		}
	}
	$profilePath = "C:\Users\$($currentUser)"
}
else {
	$user = (Get-WMIObject -ClassName Win32_ComputerSystem).Username
	$currentUser = $user.Split("\")
	$profilePath = "C:\Users\$($currentUser[1])"
}
Function Get-Folder($initialDirectory = "") {
	[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
	$folderName = New-Object System.Windows.Forms.FolderBrowserDialog
	$folderName.Description = "Select a folder"
	$folderName.rootfolder = "MyComputer"
	$folderName.SelectedPath = $initialDirectory
	if ($folderName.ShowDialog() -eq "OK") {
		$folder += $folderName.SelectedPath
	}
	return $folder
}
$migratePath = Get-Folder
New-Item -Path "$($migratePath)$($computer)\Desktop" -ItemType Directory -Force
New-Item -Path "$($migratePath)$($computer)\Documents" -ItemType Directory -Force
New-Item -Path "$($migratePath)$($computer)\Pictures" -ItemType Directory -Force
New-Item -Path "$($migratePath)$($computer)\Downloads" -ItemType Directory -Force
robocopy "$($profilePath)\Desktop" "$($migratePath)$($computer)\Desktop" /s /np /eta /xf *.lnk *.pst desktop.ini | Write-Host
robocopy "$($profilePath)\Documents" "$($migratePath)$($computer)\Documents" /s /np /eta /xf *.lnk *.pst desktop.ini | Write-Host
robocopy "$($profilePath)\Pictures" "$($migratePath)$($computer)\Pictures" /s /np /eta /xf *.lnk *.pst desktop.ini | Write-Host
robocopy "$($profilePath)\Downloads" "$($migratePath)$($computer)\Downloads" /s /np /eta /xf *.lnk *.pst desktop.ini | Write-Host