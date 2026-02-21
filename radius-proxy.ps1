# RADIUS UDP Proxy - Forwards from WiFi IP to Docker localhost
# Fixes Docker Desktop Windows UDP port forwarding issue
param(
    [string]$ListenIP = "192.168.1.227",
    [string]$TargetIP = "127.0.0.1"
)

Write-Host "=== RADIUS UDP Proxy ===" -ForegroundColor Cyan
Write-Host "Auth: $ListenIP`:1812 -> $TargetIP`:1812"
Write-Host "Acct: $ListenIP`:1813 -> $TargetIP`:1813"
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow

function Start-UdpProxy {
    param([string]$Name, [string]$ListenIP, [int]$Port, [string]$TargetIP)
    
    $listener = New-Object System.Net.Sockets.UdpClient
    $listener.Client.SetSocketOption([System.Net.Sockets.SocketOptionLevel]::Socket, 
        [System.Net.Sockets.SocketOptionName]::ReuseAddress, $true)
    $listener.Client.Bind([System.Net.IPEndPoint]::new([System.Net.IPAddress]::Parse($ListenIP), $Port))
    $listener.Client.ReceiveTimeout = 100
    
    Write-Host "[$Name] Listening on $ListenIP`:$Port" -ForegroundColor Green
    return $listener
}

$authListener = Start-UdpProxy "Auth" $ListenIP 1812 $TargetIP
$acctListener = Start-UdpProxy "Acct" $ListenIP 1813 $TargetIP

$targetAuthEP = [System.Net.IPEndPoint]::new([System.Net.IPAddress]::Parse($TargetIP), 1812)
$targetAcctEP = [System.Net.IPEndPoint]::new([System.Net.IPAddress]::Parse($TargetIP), 1813)

try {
    while ($true) {
        # Handle auth packets
        try {
            $remoteEP = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 0)
            $data = $authListener.Receive([ref]$remoteEP)
            Write-Host "[Auth] $(Get-Date -Format 'HH:mm:ss') Request from $($remoteEP.Address):$($remoteEP.Port) ($($data.Length) bytes)" -ForegroundColor Green
            
            # Forward to Docker via localhost
            $fwd = New-Object System.Net.Sockets.UdpClient
            $fwd.Send($data, $data.Length, $targetAuthEP) | Out-Null
            $fwd.Client.ReceiveTimeout = 5000
            
            try {
                $respEP = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 0)
                $resp = $fwd.Receive([ref]$respEP)
                # Send response back to MikroTik
                $authListener.Send($resp, $resp.Length, $remoteEP) | Out-Null
                $code = switch($resp[0]) { 2 {"Access-Accept"} 3 {"Access-Reject"} 11 {"Access-Challenge"} default {"Code=$($resp[0])"} }
                Write-Host "[Auth] $(Get-Date -Format 'HH:mm:ss') $code -> $($remoteEP.Address):$($remoteEP.Port) ($($resp.Length) bytes)" -ForegroundColor Cyan
            } catch {
                Write-Host "[Auth] $(Get-Date -Format 'HH:mm:ss') TIMEOUT - no response from FreeRADIUS" -ForegroundColor Red
            }
            $fwd.Close()
        } catch [System.Net.Sockets.SocketException] {
            # Timeout on receive - that's OK, just loop
        }
        
        # Handle acct packets
        try {
            $remoteEP = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 0)
            $data = $acctListener.Receive([ref]$remoteEP)
            Write-Host "[Acct] $(Get-Date -Format 'HH:mm:ss') Request from $($remoteEP.Address):$($remoteEP.Port) ($($data.Length) bytes)" -ForegroundColor Blue
            
            $fwd = New-Object System.Net.Sockets.UdpClient
            $fwd.Send($data, $data.Length, $targetAcctEP) | Out-Null
            $fwd.Client.ReceiveTimeout = 5000
            
            try {
                $respEP = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 0)
                $resp = $fwd.Receive([ref]$respEP)
                $acctListener.Send($resp, $resp.Length, $remoteEP) | Out-Null
                Write-Host "[Acct] $(Get-Date -Format 'HH:mm:ss') Response -> $($remoteEP.Address):$($remoteEP.Port) ($($resp.Length) bytes)" -ForegroundColor Cyan
            } catch {
                Write-Host "[Acct] $(Get-Date -Format 'HH:mm:ss') TIMEOUT - no response" -ForegroundColor Red
            }
            $fwd.Close()
        } catch [System.Net.Sockets.SocketException] {
            # Timeout on receive - OK
        }
    }
} finally {
    Write-Host "`nStopping proxy..." -ForegroundColor Yellow
    $authListener.Close()
    $acctListener.Close()
}
