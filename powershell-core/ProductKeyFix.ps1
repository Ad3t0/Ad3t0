slmgr.vbs /upk
Start-Sleep 5
slmgr.vbs /cpky
Start-Sleep 5
$key = wmic path softwarelicensingservice get OA3xOriginalProductKey
slmgr.vbs /ipk $key[2]
Start-Sleep 5
slmgr.vbs /ato