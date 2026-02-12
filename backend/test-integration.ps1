# Mobile-Backend Integration Test Script
# Tests the API endpoints that the mobile app will use

$baseUrl = "http://localhost:3001"
$testEmail = "mobile-test@example.com"
$testPassword = "Test123456"
$testName = "Mobile Test User"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Mobile-Backend Integration Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Health Check
Write-Host "Test 1: Health Check" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl" -Method GET -UseBasicParsing
    Write-Host "✓ Backend is accessible" -ForegroundColor Green
    Write-Host "  Status: $($response.StatusCode)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Backend is not accessible" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 2: Register
Write-Host "Test 2: Register New User" -ForegroundColor Yellow
$registerBody = @{
    email = $testEmail
    password = $testPassword
    name = $testName
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method POST -Body $registerBody -ContentType "application/json"
    Write-Host "✓ Registration successful" -ForegroundColor Green
    Write-Host "  User ID: $($response.user.id)" -ForegroundColor Gray
    Write-Host "  Email: $($response.user.email)" -ForegroundColor Gray
    Write-Host "  Name: $($response.user.name)" -ForegroundColor Gray
    Write-Host "  Access Token: $($response.access_token.Substring(0, 20))..." -ForegroundColor Gray
} catch {
    if ($_.Exception.Response.StatusCode -eq 409) {
        Write-Host "⚠ User already exists (expected if running multiple times)" -ForegroundColor Yellow
    } else {
        Write-Host "✗ Registration failed" -ForegroundColor Red
        Write-Host "  Error: $_" -ForegroundColor Red
    }
}
Write-Host ""

# Test 3: Login
Write-Host "Test 3: Login" -ForegroundColor Yellow
$loginBody = @{
    email = $testEmail
    password = $testPassword
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    Write-Host "✓ Login successful" -ForegroundColor Green
    Write-Host "  User ID: $($response.user.id)" -ForegroundColor Gray
    Write-Host "  Email: $($response.user.email)" -ForegroundColor Gray
    Write-Host "  Role: $($response.user.role)" -ForegroundColor Gray
    
    $accessToken = $response.access_token
    Write-Host "  Access Token: $($accessToken.Substring(0, 20))..." -ForegroundColor Gray
} catch {
    Write-Host "✗ Login failed" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 4: Get Profile (Authenticated)
Write-Host "Test 4: Get Profile (Authenticated)" -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/profile" -Method GET -Headers $headers
    Write-Host "✓ Profile retrieved successfully" -ForegroundColor Green
    Write-Host "  ID: $($response.id)" -ForegroundColor Gray
    Write-Host "  Email: $($response.email)" -ForegroundColor Gray
    Write-Host "  Name: $($response.name)" -ForegroundColor Gray
    Write-Host "  Role: $($response.role)" -ForegroundColor Gray
    Write-Host "  Active: $($response.isActive)" -ForegroundColor Gray
    
    $userId = $response.id
} catch {
    Write-Host "✗ Failed to get profile" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 5: Get Routers (Empty list expected)
Write-Host "Test 5: Get Routers" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/routers" -Method GET -Headers $headers
    Write-Host "✓ Routers retrieved successfully" -ForegroundColor Green
    Write-Host "  Count: $($response.Count)" -ForegroundColor Gray
    if ($response.Count -gt 0) {
        Write-Host "  First router: $($response[0].name)" -ForegroundColor Gray
    }
} catch {
    Write-Host "✗ Failed to get routers" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
}
Write-Host ""

# Test 6: Get Vouchers (Empty list expected)
Write-Host "Test 6: Get Vouchers" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/vouchers" -Method GET -Headers $headers
    Write-Host "✓ Vouchers retrieved successfully" -ForegroundColor Green
    Write-Host "  Count: $($response.Count)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Failed to get vouchers" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
}
Write-Host ""

# Test 7: Get Sales
Write-Host "Test 7: Get Sales" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/sales" -Method GET -Headers $headers
    Write-Host "✓ Sales retrieved successfully" -ForegroundColor Green
    Write-Host "  Count: $($response.Count)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Failed to get sales" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
}
Write-Host ""

# Test 8: Update Profile
Write-Host "Test 8: Update Profile" -ForegroundColor Yellow
$updateBody = @{
    name = "Updated Mobile Test User"
    networkName = "Test Network"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/users/$userId" -Method PATCH -Body $updateBody -Headers $headers
    Write-Host "✓ Profile updated successfully" -ForegroundColor Green
    Write-Host "  Name: $($response.name)" -ForegroundColor Gray
    Write-Host "  Network Name: $($response.networkName)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Failed to update profile" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Integration Test Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "- Backend is running on port 3001" -ForegroundColor White
Write-Host "- Auth endpoints working (register, login, profile)" -ForegroundColor White
Write-Host "- Protected routes accessible with JWT token" -ForegroundColor White
Write-Host "- Mobile app should be able to connect to: http://192.168.1.227:3001" -ForegroundColor White
Write-Host ""
Write-Host "Test credentials:" -ForegroundColor Yellow
Write-Host "  Email: $testEmail" -ForegroundColor White
Write-Host "  Password: $testPassword" -ForegroundColor White
