if (!([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544"))) {
    Write-Warning "Powershell is not running as Administrator. Exiting..."
    Start-Sleep 3
    Return
}
winsat formal
$out = Get-CimInstance Win32_WinSat
$score = $out.CPUScore, $out.D3DScore, $out.DiskScore, $out.GraphicsScore, $out.MemoryScore | Measure-Object -Average
$totalScore = [math]::Round($score.Average,2)
""
Write-Host "CPU Score: $($out.CPUScore)" -ForegroundColor Yellow
Write-Host "D3D Score: $($out.D3DScore)" -ForegroundColor Yellow
Write-Host "Disk Score: $($out.DiskScore)" -ForegroundColor Yellow
Write-Host "Graphics Score: $($out.GraphicsScore)" -ForegroundColor Yellow
Write-Host "Memory Score: $($out.MemoryScore)" -ForegroundColor Yellow
""
Write-Host "Total Average Score: $($totalScore)" -ForegroundColor Green