#############################################
#	Title:      ProfileMigrate		        #
#	Creator:	Ad3t0	                    #
#	Date:		05/22/2019             	    #
#############################################
$ver = "1.1.7"
$text1 = @'
     _       _ _____ _    ___
    / \   __| |___ /| |_ / _ \
   / _ \ / _` | |_ \| __| | | |
  / ___ \ (_| |___) | |_| |_| |
 /_/   \_\__,_|____/ \__|\___/
'@
$text2 = '   ProfileMigrate'
$text3 = "        Version: "
Write-Host $text1
Write-Host $text2 -ForegroundColor Yellow
Write-Host $text3 -ForegroundColor Gray -NoNewline
Write-Host $ver -ForegroundColor Green
$currentUser = (Get-WmiObject -Class Win32_Process -Filter 'Name="explorer.exe"').GetOwner().User
$currentUserProfile = "C:\Users\$($currentUser)"
$fsizeDocuments = "{0:N2} MB" -f ((Get-ChildItem "$($currentUserProfile)\Documents" -Recurse | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB)
$fsizePictures = "{0:N2} MB" -f ((Get-ChildItem "$($currentUserProfile)\Pictures" -Recurse | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB)
$fsizeDesktop = "{0:N2} MB" -f ((Get-ChildItem "$($currentUserProfile)\Desktop" -Recurse | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB)
Write-Host
Write-Host
Write-Host "$($currentUserProfile)\Documents | $fsizeDocuments" -ForegroundColor yellow
Write-Host "$($currentUserProfile)\Pictures  | $fsizePictures" -ForegroundColor yellow
Write-Host "$($currentUserProfile)\Desktop   | $fsizeDesktop" -ForegroundColor yellow
Write-Host
$currentUser = (Get-WmiObject -Class Win32_Process -Filter 'Name="explorer.exe"').GetOwner().User
$currentUserProfile = "C:\Users\$($currentUser)"
while ($migrateToPath -like '*Documents*' -or $migrateToPath -like '*Pictures*' -or $migrateToPath -like '*Desktop*' -or $migrateToPath -like '') {
	Write-Host "Type the full path to migrate the data to"
	Write-Host "Example: C:\Users\Admin\Downloads"
	Write-Host "Example: \\SERVER\SharedFolder"
	$migrateToPath = Read-Host "PATH"
	if ($migrateToPath -like '*Documents*' -or $migrateToPath -like '*Pictures*' -or $migrateToPath -like '*Desktop*' -or $migrateToPath -like '')
	{
		Write-Host "Selected folder cannot be a folder containing the path Documents, Pictures, or Desktop" -ForegroundColor red
		Write-Host
		Read-Host "Press ENTER to continue"
	}
} if ($migrateToPath -like '*_DATAPM*')
{ while ($confirmRCM -ne "n" -and $confirmRCM -ne "y")
	{
		Write-Host "Data discovered at $($migrateToPath)" -ForegroundColor green
		Write-Host
		$confirmRCM = Read-Host "Migrate data into the new profile? [y/n]"
	}
	if ($confirmRCM -eq "y")
	{
		robocopy "$($migrateToPath)\Documents\" "$($currentUserProfile)\Documents\" /s /Mov /xf *.pst desktop.ini
		robocopy "$($migrateToPath)\Pictures\" "$($currentUserProfile)\Pictures\" /s /Mov /xf *.pst desktop.ini
		robocopy "$($migrateToPath)\Desktop\" "$($currentUserProfile)\Desktop\" /s /Mov /xf *.pst desktop.ini
		robocopy "$($migrateToPath)\Favorites\" "$($currentUserProfile)\Favorites\" /s /Mov /xf *.pst desktop.ini
		if (Test-Path -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Firefox.lnk")
		{
			. "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Firefox.lnk"
			Sleep 3
			$firefoxProfile = Get-ChildItem -Path "$($currentUserProfile)\AppData\Roaming\Mozilla\Firefox\Profiles\" | Where-Object { $_.PSIsContainer } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
			Copy-Item -Path "$($migrateToPath)\Browsers\Firefox\places.sqlite" -Destination "$($currentUserProfile)\AppData\Roaming\Mozilla\Firefox\Profiles\$($firefoxProfile.Name)" -Force
		}
	}
} else
{ while ($confirmRCB -ne "n" -and $confirmRCB -ne "y")
	{ $confirmRCB = Read-Host "Profile will be copied to $($migrateToPath)\$($env:USERNAME)_DATAPM [y/n]"
	}
	if ($confirmRCB -eq "y")
	{ if (!(Test-Path -Path "$($migrateToPath)\$($env:USERNAME)_DATAPM"))
		{ New-Item -Path $migrateToPath -Name "$($env:USERNAME)_DATAPM" -ItemType "directory"
			New-Item -Path "$($migrateToPath)\$($env:USERNAME)_DATAPM\Documents" -ItemType "directory"
			New-Item -Path "$($migrateToPath)\$($env:USERNAME)_DATAPM\Pictures" -ItemType "directory"
			New-Item -Path "$($migrateToPath)\$($env:USERNAME)_DATAPM\Desktop" -ItemType "directory"
			New-Item -Path "$($migrateToPath)\$($env:USERNAME)_DATAPM\Favorites" -ItemType "directory"
			New-Item -Path "$($migrateToPath)\$($env:USERNAME)_DATAPM\Browsers\Firefox" -ItemType "directory"
			New-Item -Path "$($migrateToPath)\$($env:USERNAME)_DATAPM\Browsers\Google Chrome" -ItemType "directory"
		} robocopy "$($currentUserProfile)\Documents" "$($migrateToPath)\$($env:USERNAME)_DATAPM\Documents" /s /xf *.pst *.lnk desktop.ini
		robocopy "$($currentUserProfile)\Pictures" "$($migrateToPath)\$($env:USERNAME)_DATAPM\Pictures" /s /xf *.pst *.lnk desktop.ini
		robocopy "$($currentUserProfile)\Desktop" "$($migrateToPath)\$($env:USERNAME)_DATAPM\Desktop" /s /xf *.pst *.lnk desktop.ini
		robocopy "$($currentUserProfile)\Favorites" "$($migrateToPath)\$($env:USERNAME)_DATAPM\Favorites" /s /xf *.pst desktop.ini
		if (Test-Path -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Firefox.lnk")
		{
			. "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Firefox.lnk"
			Sleep 3
			$firefoxProfile = Get-ChildItem -Path "$($currentUserProfile)\AppData\Roaming\Mozilla\Firefox\Profiles\" | Where-Object { $_.PSIsContainer } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
			Copy-Item -Path "$($currentUserProfile)\AppData\Roaming\Mozilla\Firefox\Profiles\$($firefoxProfile.Name)\places.sqlite" -Destination "$($migrateToPath)\$($env:USERNAME)_DATAPM\Browsers\Firefox\" -Force
		}
	}
}
if ($confirmRCB -eq "n" -or $confirmRCM -eq "n")
{ Read-Host "Press ENTER to exit"
} else
{ Write-Host "Complete! Credential Manager will open next." -ForegroundColor green
} explorer.exe 'shell:::{1206F5F1-0569-412C-8FEC-3204630DFB70}'
exit
