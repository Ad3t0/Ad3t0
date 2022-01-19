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
$documentsPath = [Environment]::GetFolderPath("MyDocuments")
$downloadsPath = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
$picturesPath = [Environment]::GetFolderPath("MyPictures")
$desktopPath = [Environment]::GetFolderPath("Desktop")
New-Item -Path "$($migratePath)$($computer)\Desktop" -ItemType Directory -Force
New-Item -Path "$($migratePath)$($computer)\Documents" -ItemType Directory -Force
New-Item -Path "$($migratePath)$($computer)\Pictures" -ItemType Directory -Force
New-Item -Path "$($migratePath)$($computer)\Downloads" -ItemType Directory -Force
robocopy $documentsPath "$($migratePath)$($computer)\Desktop" /s /np /eta /xf *.lnk *.pst desktop.ini | Write-Host
robocopy $desktopPath "$($migratePath)$($computer)\Documents" /s /np /eta /xf *.lnk *.pst desktop.ini | Write-Host
robocopy $picturesPath "$($migratePath)$($computer)\Pictures" /s /np /eta /xf *.lnk *.pst desktop.ini | Write-Host
robocopy $downloadsPath "$($migratePath)$($computer)\Downloads" /s /np /eta /xf *.lnk *.pst desktop.ini | Write-Host