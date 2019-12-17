New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" –Force
$value1 = '~ WIN8RTM'
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" -Name "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" -Value $value1