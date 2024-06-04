# Capture the output of the 'query user' command and filter to find the current active session
$currentUser = query user | Select-String -Pattern "^>" -CaseSensitive

# Use a regular expression to remove the '>' character, leading spaces, and trailing session information
$username = $currentUser -replace '^>\s*', '' -replace '\s+.*$', ''

# Output the currently logged-in user
Write-Output "Currently logged-in user: $username"

$documentsPath = "C:\Users\$($username)\Documents"
$desktopPath = "C:\Users\$($username)\Desktop"
$picturesPath = "C:\Users\$($username)\Pictures"

# $downloadsPath = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
function Get-Folder($initialDirectory = "") {
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
	$folderName = New-Object System.Windows.Forms.FolderBrowserDialog
	$folderName.Description = "Select a folder"
	$folderName.rootfolder = "MyComputer"
	$folderName.SelectedPath = $initialDirectory
	if ($folderName.ShowDialog() -eq "OK") {
		$folder += $folderName.SelectedPath
		if (($folder -eq $documentsPath) -or ($folder -eq $desktopPath) -or ($folder -eq $picturesPath) -or ($folder -eq $downloadsPath) -or ($folder -eq "C:\Users")) {
			Write-Host "The destination folder can't be one of the source folders, please select another folder."
			$folder = ""
			return Get-Folder
		}
	}
	return $folder
}
Function Copy-ItemWithProgress {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[string]$Path,
		[Parameter(Mandatory = $true)]
		[string]$Destination,
		[Parameter(Mandatory = $false)]
		[string]$Filter = "*.*",
		[Parameter(Mandatory = $false)]
		[int]$ParentProgressID = 0,
		[Parameter(Mandatory = $false)]
		[int]$ProgressID = -1,
		[Parameter(Mandatory = $false)]
		[string[]] $Log = $false
	)
	$SourceDir = '"{0}"' -f ($Path -replace "\\+$", "")
	$TargetDir = '"{0}"' -f ($Destination -replace "\\+$", "")
	$ScanLog = [IO.Path]::GetTempFileName()
	$RoboLog = [IO.Path]::GetTempFileName()
	$ScanArgs = "$SourceDir $TargetDir $FilesToCopy /E /ZB /MT /R:5 /W:3 /ndl /bytes /NP /Log:$ScanLog /nfl /L"
	$RoboArgs = "$SourceDir $TargetDir $FilesToCopy /E /ZB /COPY:DATO /DCOPY:DAT /MT /R:5 /W:3 /J /ndl /bytes /Log:$RoboLog /NC"
	$ScanRun = start-process robocopy -PassThru -WindowStyle Hidden -ArgumentList $ScanArgs
	try {
		$RoboRun = start-process robocopy -PassThru -WindowStyle Hidden -ArgumentList $RoboArgs
		if ($ProgressID -lt 0) { $ProgressID = $($RoboRun.Id) }
		Write-Verbose -Message "ParentProgressID $ParentProgressID"
		Write-Verbose -Message "ProgressID $ProgressID"
		try {
			$CurrentFile = "Skipped"
			$CurrentFilePercent = $null
			If ($VerbosePreference -eq "Continue") {
				Write-Verbose "Waiting on ScanRun PID $($ScanRun.Id)"
				While (-not $ScanRun.HasExited) {
					Start-Sleep -Seconds 1
					$Seconds++
					If ($PsISE) {
						Write-Host "." -ForegroundColor Cyan -NoNewline
					}
					Else {
						Write-Host "`rScanRun PID $($ScanRun.Id) - (Running for $Seconds seconds)" -NoNewline -ForegroundColor Cyan
					}
				}
				Write-Host `r`n -NoNewline
				Write-Verbose "ScanRun PID $($ScanRun.Id) Completed"
			}
			$ScanRun.WaitForExit()
			# Parse Robocopy "Scan" pass
			$LogData = get-content $ScanLog
			if ($ScanRun.ExitCode -ge 8) {
				$LogData | out-string | Write-Error
				Write-Warning "ScanRun ExitCode: $($ScanRun.ExitCode)"
			}
			$FilesLengthSum = [regex]::Match($LogData[-4], ".+:\s+(\d+)\s+(\d+)").Groups[2].Value
			# Monitor Full RoboCopy
			write-progress -Activity "ROBOCOPY $Source to $Destination" -PercentComplete 0 -Id $ProgressID -ParentId $ParentProgressID
			while (-not $($RoboRun.HasExited)) {
				Start-Sleep -Milliseconds 100
				$LogData = get-content $RoboLog
				$Files = $LogData -match "^\s*(\d+)\s+(\S+)"
				if (!([string]::IsNullOrEmpty($Files))) {
					$CopiedLength = ($Files[0..($Files.Length - 2)] | ForEach-Object { $_.Split("`t")[-2] } | Measure-Object -sum).Sum
					$File = $Files[-1].Split("`t")[-1]
					$FileLength = $Files[-1].Split("`t")[-2]
					write-progress -Activity "ROBOCOPY $Source to $Destination" -Status "$([math]::Round($($CopiedLength / 1MB),2)) MB of $([math]::Round($($FilesLengthSum / 1MB), 2)) MB" -PercentComplete $($CopiedLength / $FilesLengthSum * 100) -Id $ProgressID -ParentId $ParentProgressID
					if ($LogData[-1] -match "(100|\d?\d)\%") {
						$FilePercent = $LogData[-1].Trim("% `t")
						If (($File -eq $CurrentFile) -and ($FilePercent -eq $CurrentFilePercent)) { Continue }
						$CurrentFile = $File
						$CurrentFilePercent = $FilePercent
						write-progress -Activity "$file" -Status "$([math]::Round($($FileLength / 100 * $FilePercent / 1MB),2)) MB of $([math]::Round($($FileLength / 1MB), 2)) MB" -PercentComplete $FilePercent -ParentID $ProgressID -Id $($ProgressID + 100)
					}
					else {
						If ($File -eq $CurrentFile) { Continue }
						write-progress -Activity "$file" -Status "$([math]::Round($($FileLength / 1MB),2)) MB of $([math]::Round($($FileLength / 1MB), 2)) MB" -PercentComplete "100" -ParentID $ProgressID -Id $($ProgressID + 100)
					}
				}
			}
		}
		finally {
			$RoboRun.WaitForExit()
			Write-progress -Activity "$CurrentFile" -ParentID $ProgressID -Id $($ProgressID + 100) -Completed
			Write-Progress -Activity "ROBOCOPY $Source to Destination" -Id $ProgressID -ParentId $ParentProgressID -Completed
			# Parse full RoboCopy pass results, and cleanup
            (get-content $RoboLog)[-11..-2] | out-string | Write-Verbose
			If ($Log) { Copy-Item -Path $RoboLog -Destination "$Log" }
			remove-item $RoboLog
		}
	}
 finally {
		if (!$ScanRun.HasExited) { Write-Warning "Terminating scan process with ID $($ScanRun.Id)..."; $ScanRun.Kill() }
		$ScanRun.WaitForExit()
		remove-item $ScanLog
	}
}
while ($null -eq $migratePath) {
	$migratePath = Get-Folder
	if ($null -eq $migratePath) {
		Write-Host "No path was selected. Please select a path."
		Start-Sleep 5
	}
}
$destinationPath = "$($migratePath)\$($username)\Documents"
Copy-ItemWithProgress -Path $documentsPath -Destination $destinationPath
$destinationPath = "$($migratePath)\$($username)\Desktop"
Copy-ItemWithProgress -Path $desktopPath -Destination $destinationPath
$destinationPath = "$($migratePath)\$($username)\Pictures"
Copy-ItemWithProgress -Path $picturesPath -Destination $destinationPath
# $destinationPath = "$($migratePath)\$($username)\Downloads"
# Copy-ItemWithProgress -Path $downloadsPath -Destination $destinationPath
if (Test-Path -Path "C:\Users\$($username)\AppData\Local\Google\Chrome\User Data\Default\Bookmarks") {
	$ChromeBookmarksPath = "C:\Users\$($username)\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"
	$ExportFile = "$($migratePath)\$($username)\chrome_bookmarks.html"
	Export-Clixml -InputObject (Get-Content $ChromeBookmarksPath | ConvertFrom-Json) -Path $ExportFile
}