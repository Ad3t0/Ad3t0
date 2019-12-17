$file1 = Import-Csv -Path "C:\Users\Administrator\Downloads\more.csv"
$file2 = Import-Csv -Path "C:\Users\Administrator\Downloads\less.csv"
$test = Compare-Object $file1 $file2 -Property Test1 -PassThru | Get-Unique
$test.PSObject.properties.remove('SideIndicator')
$test | Export-Csv -NoTypeInformation -Path "C:\Users\Administrator\Downloads\uni.csv"
