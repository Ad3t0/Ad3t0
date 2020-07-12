if (!([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544"))) {
    Write-Warning "Powershell is not running as Administrator. Exiting..."
    Start-Sleep 3
    Return
}
$PSVer = $PSVersionTable
if ($PSVer.PSVersion.Major -lt 5) {
    Write-Warning "Powershell version is $($PSVer.PSVersion.Major). Version 5.1 is needed please update using the following web page. Exiting..."
    Start-Sleep 3
    $URL = "https://www.microsoft.com/en-us/download/details.aspx?id=54616"
    Start-Process $URL
    Return
}
if (!(Test-Path "C:\Windows\System32\msra.exe")) {
	Write-Warning "Microsoft Remote Assistant is not installed. Exiting..."
	Start-Sleep 6
	exit
}
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
$Form = New-Object system.Windows.Forms.Form
$Form.ClientSize = '400,546'
$Form.FormBorderStyle = 'Fixed3D'
$Form.MaximizeBox = $false
$Form.text = "MSRA Quick Connect"
$Form.TopMost = $false
$Path = "C:\Windows\System32\msra.exe"
$Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($Path)
$Form.Icon = $Icon
$ListBox1 = New-Object system.Windows.Forms.ListBox
$ListBox1.text = "listBox"
$ListBox1.width = 367
$ListBox1.height = 190
$ListBox1.location = New-Object System.Drawing.Point (16, 300)
$Button1 = New-Object system.Windows.Forms.Button
$Button1.text = "Connect"
$Button1.width = 102
$Button1.height = 30
$Button1.location = New-Object System.Drawing.Point (190, 501)
$Button1.Font = 'Microsoft Sans Serif,10'
$Button1.Enabled = $False
$Button2 = New-Object system.Windows.Forms.Button
$Button2.text = "Exit"
$Button2.width = 83
$Button2.height = 30
$Button2.location = New-Object System.Drawing.Point (302, 501)
$Button2.Font = 'Microsoft Sans Serif,10'
$ListBox2 = New-Object system.Windows.Forms.ListBox
$ListBox2.text = "listBox"
$ListBox2.width = 367
$ListBox2.height = 250
$ListBox2.location = New-Object System.Drawing.Point (16, 27)
$Label1 = New-Object system.Windows.Forms.Label
$Label1.text = "Domain Users"
$Label1.AutoSize = $true
$Label1.width = 25
$Label1.height = 10
$Label1.location = New-Object System.Drawing.Point (6, 6)
$Label1.Font = 'Microsoft Sans Serif,10'
$Label2 = New-Object system.Windows.Forms.Label
$Label2.text = "Active Desktops"
$Label2.AutoSize = $true
$Label2.width = 25
$Label2.height = 10
$Label2.location = New-Object System.Drawing.Point (6, 280)
$Label2.Font = 'Microsoft Sans Serif,10'
$Label3 = New-Object system.Windows.Forms.Label
$Label3.text = $ver
$Label3.AutoSize = $true
$Label3.width = 25
$Label3.height = 10
$Label3.location = New-Object System.Drawing.Point (6, 525)
$Label3.Font = 'Microsoft Sans Serif,8'
$Form.controls.AddRange(@($ListBox1, $Button1, $Button2, $ListBox2, $Label1, $Label2, $Label3))
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$adComputers = Get-ADComputer -Filter { OperatingSystem -NotLike "Windows Server*" } | Select-Object -ExpandProperty Name
$adComputersTested = { $adComputersTested }.Invoke()
$adComputersTested.Clear()
Write-Host "Loading Active Desktops Please Wait..." -ForegroundColor Green
Write-Host
Write-Host "Successfully Pinged:"
foreach ($computer in $adComputers) {
 if (Test-Connection $computer -Quiet -Count 1) {
		$adComputersTested.Add($computer)
		Write-Host $computer
	}
}
Write-Host
function Get-TSSessions {
	param(
		$ComputerName
	)
	C:\Windows\System32\query.exe user /server:$ComputerName |
	ForEach-Object {
		$_ = $_.trim()
		$_ = $_.insert(22, ",").insert(42, ",").insert(47, ",").insert(56, ",").insert(68, ",")
		$_ = $_ -replace "\s\s+", ""
		$_
	} |
	ConvertFrom-Csv
}
$testedUsersArray = { $testedUsersArray }.Invoke()
$testedUsersArray.Clear()
Write-Host "Active Desktop Sessions:"
foreach ($computer in $adComputersTested) {
	$testedUsers = Get-TSSessions ($ComputerName = $computer) | Select-Object -ExpandProperty USERNAME
	foreach ($user in $testedUsers) {
		$testedUsersArray.Add($user + "~" + $computer)
		Write-Host "$($user)@$($computer)"
	}
}
function Hide-Console {
	$consolePtr = [Console.Window]::GetConsoleWindow()
	[Console.Window]::ShowWindow($consolePtr, 0)
}
Hide-Console
$Button2.Add_Click(
	{
		$Form.Close()
	}
)
$ListBox2ItemsToAdd = { $ListBox2ItemsToAdd }.Invoke()
$ListBox2ItemsToAdd.Clear()
foreach ($item in $testedUsersArray) {
	$addItem = $item.Split("~")
	if ($addItem[0] -ne "") {
		$ListBox2ItemsToAdd.Add($addItem[0])
	}
}
$ListBox2ItemsToAdd = $ListBox2ItemsToAdd | Select-Object -Unique
foreach ($item in $ListBox2ItemsToAdd) {
	$ListBox2.Items.Add($item)
}
$Form.controls.Add($ListBox2)
$Button1.Add_Click(
	{
		if ($ListBox2.SelectedItem -and $ListBox1.SelectedItem) {
			C:\Windows\System32\msra.exe /offerra $ListBox1.SelectedItem
		}
	}
)
$ListBox2.add_SelectedIndexChanged(
	{
		$ListBox1.Items.Clear()
		if ($ListBox1.SelectedItem) {
			$Button1.Enabled = $True
		}
		else {
			$Button1.Enabled = $False
		}
		$ListBox1.Items.Clear()
		if ($ListBox2.SelectedItem) {
			foreach ($item in $testedUsersArray) {
				if ($item -like "*$($ListBox2.SelectedItem)*") {
					$addItem = $item.Split("~")
					$ListBox1.Items.Add($addItem[1])
				}
			}
		}
		$Form.controls.Add($ListBox1)
	}
)
$ListBox1.add_SelectedIndexChanged(
	{
		if ($ListBox1.SelectedItem) {
			$Button1.Enabled = $True
		}
		else {
			$Button1.Enabled = $False
		}
	}
)
$Form.ShowDialog()
$Form.Dispose()
