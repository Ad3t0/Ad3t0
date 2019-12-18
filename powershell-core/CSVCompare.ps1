$file1 = Import-Csv -Path "C:\Users\Administrator\Downloads\Mock Up - Opportunities.csv"
$file2 = Import-Csv -Path "C:\Users\Administrator\Downloads\Mock Up - All Data.csv"
$test = Compare-Object $file1 $file2 -Property Company -PassThru #| Get-Unique
$dupes = Compare-Object $file1 $file2 -Property Company -PassThru -IncludeEqual -ExcludeDifferent
$dupes = $dupes | ForEach-Object {$_.Company}
$test = $test | Where-Object {$_.SideIndicator -eq "=>"}

foreach($company in $test)
{
    $company.Company = $company.Company.Replace("-","").Replace(" ","")
}
foreach ($dupe in $dupes) {
    
    $dupe = $dupe.Replace("-","").Replace(" ","")

    $test = $test | Where-Object {$_.Company -ne "*$($dupe)*"}
}

#$test = $test.PSObject.properties.remove('SideIndicator')
#$test | Export-Csv -NoTypeInformation -Path "C:\Users\Administrator\Downloads\uni.csv"
