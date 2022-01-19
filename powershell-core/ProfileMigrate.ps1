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
$downloadsPath = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
$picturesPath = [Environment]::GetFolderPath("MyPictures")
$desktopPath = [Environment]::GetFolderPath("Desktop")
New-Item -Path "$($migratePath)\$($refName)\Desktop" -ItemType Directory -Force
New-Item -Path "$($migratePath)\$($refName)\Documents" -ItemType Directory -Force
New-Item -Path "$($migratePath)\$($refName)\Pictures" -ItemType Directory -Force
New-Item -Path "$($migratePath)\$($refName)\Downloads" -ItemType Directory -Force
robocopy $documentsPath "$($migratePath)\$($refName)\Desktop" /s /np /eta /xf *.lnk *.pst *.exe desktop.ini | Write-Host
robocopy $desktopPath "$($migratePath)\$($refName)\Documents" /s /np /eta /xf *.lnk *.pst *.exe desktop.ini | Write-Host
robocopy $picturesPath "$($migratePath)\$($refName)\Pictures" /s /np /eta /xf *.lnk *.pst *.exe desktop.ini | Write-Host
robocopy $downloadsPath "$($migratePath)\$($refName)\Downloads" /s /np /eta /xf *.lnk *.pst *.exe desktop.ini | Write-Host