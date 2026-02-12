# Simple Backend API Test
# Quick test to verify backend is working

$baseUrl = "http://localhost:3001"

Write-Host "Testing Backend API..." -ForegroundColor Cyan
Write-Host ""

# Test 1: Register a new user
Write-Host "1. Registering new user..." -ForegroundColor Yellow
$registerBody = @{
    email = "testuser$(Get-Random -Maximum 9999)@example.com"
    password = "Password123!"
    name = "Test User"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method POST -Body $registerBody -ContentType "application/json"
    Write-Host "✓ Registration successful" -ForegroundColor Green
    $testEmail = ($registerBody | ConvertFrom-Json).email
    $testPassword = ($registerBody | ConvertFrom-Json).password
    $accessToken = $registerResponse.accessToken
    Write-Host "  Email: $testEmail" -ForegroundColor Gray
    Write-Host "  Token: $($accessToken.Substring(0, 30))..." -ForegroundColor Gray
} catch {
    Write-Host "✗ Registration failed: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 2: Login with the same user
Write-Host "2. Testing login..." -ForegroundColor Yellow
$loginBody = @{
    email = $testEmail
    password = $testPassword
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    Write-Host "✓ Login successful" -ForegroundColor Green
    Write-Host "  User: $($loginResponse.user.name)" -ForegroundColor Gray
    Write-Host "  Role: $($loginResponse.user.role)" -ForegroundColor Gray
    $accessToken = $loginResponse.accessToken
} catch {
    Write-Host "✗ Login failed: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 3: Get profile
Write-Host "3. Testing authenticated endpoint..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $accessToken"
}

try {
    $profileResponse = Invoke-RestMethod -Uri "$baseUrl/auth/profile" -Method GET -Headers $headers
    Write-Host "✓ Profile retrieved" -ForegroundColor Green
    Write-Host "  ID: $($profileResponse.id)" -ForegroundColor Gray
    Write-Host "  Email: $($profileResponse.email)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Profile retrieval failed: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 4: Get routers
Write-Host "4. Testing routers endpoint..." -ForegroundColor Yellow
try {
    $routersResponse = Invoke-RestMethod -Uri "$baseUrl/routers" -Method GET -Headers $headers
    Write-Host "✓ Routers endpoint working" -ForegroundColor Green
    Write-Host "  Router count: $($routersResponse.Count)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Routers endpoint failed: $_" -ForegroundColor Red
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Backend API is working correctly!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Test credentials for mobile app:" -ForegroundColor Yellow
Write-Host "  Email: $testEmail" -ForegroundColor White
Write-Host "  Password: $testPassword" -ForegroundColor White
Write-Host ""
Write-Host "Mobile app should connect to:" -ForegroundColor Yellow
Write-Host "  http://192.168.1.227:3001" -ForegroundColor White
