$baseUrl = "http://localhost:3000"
$email = "admin@example.com"
$password = "SecurePass123"

# 1. Login
$loginBody = @{
    email = $email
    password = $password
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.accessToken
    Write-Host "Login Successful. Token received." -ForegroundColor Green
} catch {
    Write-Host "Login Failed: $_" -ForegroundColor Red
    exit
}

$headers = @{
    Authorization = "Bearer $token"
}

# 2. Get Routers
try {
    $routers = Invoke-RestMethod -Uri "$baseUrl/routers" -Method Get -Headers $headers
    if ($routers.Count -eq 0) {
        Write-Host "No routers found. Please add a router first." -ForegroundColor Yellow
        exit
    }
    $routerId = $routers[0].id
    Write-Host "Using Router ID: $routerId" -ForegroundColor Cyan
} catch {
    Write-Host "Failed to get routers: $_" -ForegroundColor Red
    exit
}

# 3. Get Router Stats
try {
    Write-Host "Fetching stats for router..."
    $stats = Invoke-RestMethod -Uri "$baseUrl/routers/$routerId/stats" -Method Get -Headers $headers
    Write-Host "Stats Received:" -ForegroundColor Green
    $stats | ConvertTo-Json -Depth 5 | Write-Host
} catch {
    Write-Host "Failed to get stats: $_" -ForegroundColor Red
    Write-Host "Response Body: $($_.ErrorDetails.Message)" -ForegroundColor Red
}
