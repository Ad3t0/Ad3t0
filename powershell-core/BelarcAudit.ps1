#############################################
#	Title:      BelarcAudit  			    #
#	Creator:	Ad3t0	                    #
#	Date:		04/16/2019             	    #
#############################################
$ver = "1.1.8"
$text1 = @'
     _       _ _____ _    ___
    / \   __| |___ /| |_ / _ \
   / _ \ / _` | |_ \| __| | | |
  / ___ \ (_| |___) | |_| |_| |
 /_/   \_\__,_|____/ \__|\___/
'@
$text2 = '       BelarcAudit'
$text3 = "        Version: "
Write-Host $text1
Write-Host $text2 -ForegroundColor Yellow
Write-Host $text3 -ForegroundColor Gray -NoNewline
Write-Host $ver -ForegroundColor Green
$user = Read-Host "Username"
$pass = Read-Host "Password"
$folderOrganize = Read-Host "Enter sub-folder name"
Clear-Host
if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64")
{ $output = "$(${env:ProgramFiles(x86)})\Belarc\BelarcAdvisor\System\tmp\($($env:COMPUTERNAME)).html"
	$belarcinstall = "$(${env:ProgramFiles(x86)})\Belarc\BelarcAdvisor\BelarcAdvisor.exe"
} else
{ $output = "$($env:ProgramFiles)\Belarc\BelarcAdvisor\System\tmp\($($env:COMPUTERNAME)).html"
	$belarcinstall = "$($env:ProgramFiles)\Belarc\BelarcAdvisor\BelarcAdvisor.exe"
} Remove-Item $output > $null 2>&1
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n=allowGlobalConfirmation
choco feature disable -n=checksumFiles
if (Test-Path $belarcinstall)
{.$belarcinstall
} else {
	choco install belarcadvisor
} choco install megatools
Remove-Item "$($env:PUBLIC)\Desktop\Belarc Advisor.lnk" > $null 2>&1
while (!(Test-Path $output)) {
	Start-Start-Sleep 10
} megamkdir "/Root/Audit/$($folderOrganize)" -u $user -p $pass
megaput --path "/Root/Audit/$($folderOrganize)" -u $user -p $pass $output
exit
