Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "/c cscript C:\Windows\System32\slmgr.vbs /upk" -Wait -PassThru
Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "/c cscript C:\Windows\System32\slmgr.vbs /cpky" -Wait -PassThru
$key = wmic path softwarelicensingservice get OA3xOriginalProductKey
Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "/c cscript C:\Windows\System32\slmgr.vbs /ipk $($key[2])" -Wait -PassThru
Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "/c cscript C:\Windows\System32\slmgr.vbs /ato" -Wait -PassThru