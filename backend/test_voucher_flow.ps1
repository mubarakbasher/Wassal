# Test Voucher Generation Flow

$baseUrl = "http://localhost:3000"
$adminEmail = "admin@example.com"
$adminPassword = "SecurePass123"

# 1. Login
Write-Host "1. Logging in..." -ForegroundColor Yellow
$loginBody = @{ email = $adminEmail; password = $adminPassword } | ConvertTo-Json
try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Headers @{"Content-Type"="application/json"} -Body $loginBody
    $token = $loginResponse.accessToken
    Write-Host "   Login success." -ForegroundColor Green
} catch {
    Write-Host "   Login failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# 2. Get Router
Write-Host "2. Getting Router..." -ForegroundColor Yellow
try {
    $routers = Invoke-RestMethod -Uri "$baseUrl/routers" -Method GET -Headers $headers
    if ($routers.Count -eq 0) {
        Write-Host "   No routers found! Please add a router first." -ForegroundColor Red
        exit 1
    }
    $router = $routers[0] # Pick the first one
    $routerId = $router.id
    Write-Host "   Using Router: $($router.name) ($routerId)" -ForegroundColor Green
} catch {
    Write-Host "   Failed to get routers: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 3. Get or Create 'default' Profile
Write-Host "3. getting/Creating 'default' Profile..." -ForegroundColor Yellow
$profileName = "default"
$profileId = $null

try {
    # Check if exists
    $profiles = Invoke-RestMethod -Uri "$baseUrl/profiles?routerId=$routerId" -Method GET -Headers $headers
    $existing = $profiles | Where-Object { $_.name -eq $profileName }

    if ($existing) {
        $profileId = $existing.id
        Write-Host "   Found existing 'default' profile ($profileId)" -ForegroundColor Green
    } else {
        # Create it
         $profileBody = @{
            routerId = $routerId
            name = $profileName
            rateLimit = "1M/1M"
            sharedUsers = 1
        } | ConvertTo-Json

        $profile = Invoke-RestMethod -Uri "$baseUrl/profiles" -Method POST -Headers $headers -Body $profileBody
        $profileId = $profile.id
        Write-Host "   Created 'default' profile ($profileId)" -ForegroundColor Green
    }
} catch {
    Write-Host "   Failed to handle profile: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 4. Generate Voucher
Write-Host "4. Generating Voucher..." -ForegroundColor Yellow
$voucherBody = @{
    routerId = $routerId
    profileId = $profileId
    planType = "TIME_BASED"
    planName = "1 Hour Test"
    duration = 60
    price = 10.0
    quantity = 1
} | ConvertTo-Json

$voucherId = $null

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/vouchers" -Method POST -Headers $headers -Body $voucherBody
    $voucher = $response.vouchers[0]
    $voucherId = $voucher.id
    Write-Host "   Voucher Generated: $($voucher.username) / $($voucher.password)" -ForegroundColor Green
    Write-Host "   Voucher ID: $voucherId" -ForegroundColor Gray
} catch {
    Write-Host "   Failed to generate voucher: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 5. Activate Voucher (Push to MikroTik)
Write-Host "5. Activating Voucher (Push to MikroTik)..." -ForegroundColor Yellow
try {
    $activation = Invoke-RestMethod -Uri "$baseUrl/vouchers/$voucherId/activate" -Method PATCH -Headers $headers
    Write-Host "   Voucher Activated Successfully!" -ForegroundColor Green
    Write-Host "   Status: $($activation.status)" -ForegroundColor Gray
    Write-Host "   MikroTik Confirmation: Hotspot User '$($activation.username)' created." -ForegroundColor Green
} catch {
    Write-Host "   Failed to activate voucher: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
         $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
         Write-Host "   Details: $($reader.ReadToEnd())" -ForegroundColor Red
    }
}

Write-Host "Test Complete." -ForegroundColor Cyan
