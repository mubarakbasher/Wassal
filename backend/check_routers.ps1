# Check Router Connection Script

$baseUrl = "http://localhost:3000"
$adminEmail = "admin@example.com"
$adminPassword = "SecurePass123"

# 1. Login
Write-Host "Logging in as Admin..." -ForegroundColor Yellow
$loginBody = @{ email = $adminEmail; password = $adminPassword } | ConvertTo-Json
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

# 2. List Routers
Write-Host "Listing Routers..." -ForegroundColor Yellow
try {
    $routers = Invoke-RestMethod -Uri "$baseUrl/routers" -Method GET -Headers $headers
    
    if ($routers.Count -eq 0) {
        Write-Host "No routers found in the database." -ForegroundColor Yellow
        Write-Host "To test connection, you need to add a router or provide credentials." -ForegroundColor Gray
    } else {
        Write-Host "Found $($routers.Count) routers. Checking health..." -ForegroundColor Green
        
        foreach ($router in $routers) {
            Write-Host "Checking router: $($router.name) ($($router.ipAddress))..." -NoNewline
            try {
                $health = Invoke-RestMethod -Uri "$baseUrl/routers/$($router.id)/health" -Method GET -Headers $headers
                if ($health.isOnline) {
                    Write-Host " [ONLINE]" -ForegroundColor Green
                } else {
                    Write-Host " [OFFLINE]" -ForegroundColor Red
                }
            } catch {
                Write-Host " [ERROR: $($_.Exception.Message)]" -ForegroundColor Red
            }
        }
    }
} catch {
    Write-Host "Failed to list routers: $($_.Exception.Message)" -ForegroundColor Red
}
