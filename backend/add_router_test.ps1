# Add Router Test Script

$baseUrl = "http://localhost:3000"
$adminEmail = "admin@example.com"
$adminPassword = "SecurePass123"

# Router Details
$routerName = "MikroTik Test Router"
$routerIp = "192.168.1.190"
$routerUser = "admin"
$routerPass = "asdf@1234"
$routerPort = 8728

# 1. Login
Write-Host "Logging in as Admin..." -ForegroundColor Yellow
$loginBody = @{
    email = $adminEmail
    password = $adminPassword
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Headers @{"Content-Type"="application/json"} -Body $loginBody
    $token = $loginResponse.accessToken
    Write-Host "Login Success." -ForegroundColor Green
} catch {
    Write-Host "Login Failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# 2. Add Router
Write-Host "Attempting to add router and connect to $routerIp..." -ForegroundColor Yellow
$routerBody = @{
    name = $routerName
    ipAddress = $routerIp
    username = $routerUser
    password = $routerPass
    apiPort = $routerPort
    location = "Test Location"
    description = "Test Router added via script"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/routers" -Method POST -Headers $headers -Body $routerBody
    Write-Host "SUCCESS: Router Added!" -ForegroundColor Green
    Write-Host "ID: $($response.id)" -ForegroundColor Gray
    Write-Host "Name: $($response.name)" -ForegroundColor Gray
    Write-Host "Status: $($response.status)" -ForegroundColor Gray
} catch {
    Write-Host "FAILED to add router." -ForegroundColor Red
    $msg = $_.Exception.Message
    Write-Host "Error: $msg" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $details = $reader.ReadToEnd()
        Write-Host "Details: $details" -ForegroundColor Red
    }
}
