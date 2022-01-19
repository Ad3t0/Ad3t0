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
$refName = Read-Host "Enter migration name for reference"
$migratePath = Get-Folder
$documentsPath = [Environment]::GetFolderPath("MyDocuments")
$desktopPath = [Environment]::GetFolderPath("Desktop")
$picturesPath = [Environment]::GetFolderPath("MyPictures")
$downloadsPath = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
robocopy $documentsPath "$($migratePath)\$($refName)\Documents" /s /np /eta /xf *.lnk *.pst *.exe *.dll desktop.ini | Write-Host
robocopy $desktopPath "$($migratePath)\$($refName)\Desktop" /s /np /eta /xf *.lnk *.pst *.exe *.dll desktop.ini | Write-Host
robocopy $picturesPath "$($migratePath)\$($refName)\Pictures" /s /np /eta /xf *.lnk *.pst *.exe *.dll desktop.ini | Write-Host
robocopy $downloadsPath "$($migratePath)\$($refName)\Downloads" /s /np /eta /xf *.lnk *.pst *.exe *.dll desktop.ini | Write-Host