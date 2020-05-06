$portrange = Read-Host "Enter port"
$intIP = Test-Connection -ComputerName $env:COMPUTERNAME -Count 1
$intIP = $intIP.IPV4Address.IPAddressToString.Split(".")
$net = "$($intIP[0]).$($intIP[1]).$($intIP[2])"
$range = 1..255
$timeout_ms = 50
foreach ($r in $range) {
	$ip = "{0}.{1}" -F $net, $r
	if (Test-Connection -BufferSize 32 -Count 1 -Quiet -ComputerName $ip) {
		Write-Host "IP $ip is alive... checking ports..."
		foreach ($port in $portrange) {
			$ErrorActionPreference = 'SilentlyContinue'
			$socket = new-object System.Net.Sockets.TcpClient
			$connect = $socket.BeginConnect($ip, $port, $null, $null)
			$tryconnect = Measure-Command { $connect.AsyncWaitHandle.WaitOne($timeout_ms, $true) } | ForEach-Object totalmilliseconds
			$tryconnect | Out-Null
			if ($socket.Connected) {
				Write-Host "$ip is listening on port $port (Response Time: $tryconnect ms)" -ForegroundColor Green
				$socket.Close()
				$socket.Dispose()
				$socket = $null
			}
			$ErrorActionPreference = 'Continue'
		}
	}
}