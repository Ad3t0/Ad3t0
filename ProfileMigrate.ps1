#############################################
#	Title:      ProfileMigrate		        #
#	Creator:	Ad3t0	                    #
#	Date:		05/22/2019             	    #
#############################################
$ver = "1.1.5"
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
$fsizeDocuments = "{0:N2} MB" -f ((Get-ChildItem "$($env:USERPROFILE)\Documents" -Recurse | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB)
$fsizePictures = "{0:N2} MB" -f ((Get-ChildItem "$($env:USERPROFILE)\Pictures" -Recurse | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB)
$fsizeDesktop = "{0:N2} MB" -f ((Get-ChildItem "$($env:USERPROFILE)\Desktop" -Recurse | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB)
Write-Host
Write-Host
Write-Host "$($env:USERPROFILE)\Documents | $fsizeDocuments" -ForegroundColor yellow
Write-Host "$($env:USERPROFILE)\Pictures  | $fsizePictures" -ForegroundColor yellow
Write-Host "$($env:USERPROFILE)\Desktop   | $fsizeDesktop" -ForegroundColor yellow
Write-Host
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
}if ($migrateToPath -like '*_DATAPM*')
{ while ($confirmRCM -ne "n" -and $confirmRCM -ne "y")
	{
		Write-Host "Data discovered at $($migrateToPath)" -ForegroundColor green
		Write-Host
		$confirmRCM = Read-Host "Migrate data into the new profile? [y/n]"
	}
	if ($confirmRCM -eq "y")
	{
		robocopy "$($migrateToPath)\Documents\" "$($env:USERPROFILE)\Documents\" /s /xf *.pst desktop.ini
		robocopy "$($migrateToPath)\Pictures\" "$($env:USERPROFILE)\Pictures\" /s /xf *.pst desktop.ini
		robocopy "$($migrateToPath)\Desktop\" "$($env:USERPROFILE)\Desktop\" /s /xf *.pst desktop.ini
		robocopy "$($migrateToPath)\Favorites\" "$($env:USERPROFILE)\Favorites\" /s /xf *.pst desktop.ini
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
		} robocopy "$($env:USERPROFILE)\Documents" "$($migrateToPath)\$($env:USERNAME)_DATAPM\Documents" /s /xf *.pst *.lnk desktop.ini
		robocopy "$($env:USERPROFILE)\Pictures" "$($migrateToPath)\$($env:USERNAME)_DATAPM\Pictures" /s /xf *.pst *.lnk desktop.ini
		robocopy "$($env:USERPROFILE)\Desktop" "$($migrateToPath)\$($env:USERNAME)_DATAPM\Desktop" /s /xf *.pst *.lnk desktop.ini
		robocopy "$($env:USERPROFILE)\Favorites" "$($migrateToPath)\$($env:USERNAME)_DATAPM\Favorites" /s /xf *.pst desktop.ini
	}
} if ($confirmRCB -eq "n" -or $confirmRCM -eq "n")
{ Read-Host "Press ENTER to exit"
} else
{ Write-Host "Complete! Credential Manager will open next." -ForegroundColor green
} explorer.exe 'shell:::{1206F5F1-0569-412C-8FEC-3204630DFB70}'
exit
