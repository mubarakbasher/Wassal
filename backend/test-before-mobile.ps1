# Quick Backend API Test - Verify CORS and Endpoints
# Run this before mobile testing

$baseUrl = "http://localhost:3001"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Backend API Quick Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Health Check
Write-Host "1. Testing backend accessibility..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl" -Method GET -UseBasicParsing
    Write-Host "✓ Backend is running" -ForegroundColor Green
    Write-Host "  Status: $($response.StatusCode)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Backend is not accessible" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please start the backend:" -ForegroundColor Yellow
    Write-Host "  cd backend" -ForegroundColor White
    Write-Host "  npm run start:dev" -ForegroundColor White
    exit 1
}
Write-Host ""

# Test 2: CORS Headers
Write-Host "2. Testing CORS configuration..." -ForegroundColor Yellow
try {
    $headers = @{
        "Origin" = "http://localhost:8080"
        "Access-Control-Request-Method" = "POST"
        "Access-Control-Request-Headers" = "Content-Type,Authorization"
    }
    $response = Invoke-WebRequest -Uri "$baseUrl/auth/login" -Method OPTIONS -Headers $headers -UseBasicParsing
    
    $corsHeader = $response.Headers["Access-Control-Allow-Origin"]
    if ($corsHeader) {
        Write-Host "✓ CORS is enabled" -ForegroundColor Green
        Write-Host "  Allow-Origin: $corsHeader" -ForegroundColor Gray
    } else {
        Write-Host "⚠ CORS headers not found" -ForegroundColor Yellow
        Write-Host "  This might cause issues with mobile app" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠ Could not verify CORS (this is OK if backend doesn't support OPTIONS)" -ForegroundColor Yellow
}
Write-Host ""

# Test 3: Register Test User
Write-Host "3. Creating test user..." -ForegroundColor Yellow
$testEmail = "mobiletest$(Get-Random -Maximum 999)@example.com"
$testPassword = "Test123456"

$registerBody = @{
    email = $testEmail
    password = $testPassword
    name = "Mobile Test User"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method POST -Body $registerBody -ContentType "application/json"
    Write-Host "✓ Test user created" -ForegroundColor Green
    Write-Host "  Email: $testEmail" -ForegroundColor Gray
    Write-Host "  Password: $testPassword" -ForegroundColor Gray
    Write-Host "  User ID: $($response.user.id)" -ForegroundColor Gray
    
    $accessToken = $response.accessToken
    $userId = $response.user.id
} catch {
    Write-Host "✗ Failed to create test user" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 4: Login
Write-Host "4. Testing login..." -ForegroundColor Yellow
$loginBody = @{
    email = $testEmail
    password = $testPassword
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    Write-Host "✓ Login successful" -ForegroundColor Green
    Write-Host "  Token: $($response.accessToken.Substring(0, 30))..." -ForegroundColor Gray
    
    $accessToken = $response.accessToken
} catch {
    Write-Host "✗ Login failed" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 5: Protected Route (Routers)
Write-Host "5. Testing protected route (GET /routers)..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/routers" -Method GET -Headers $headers
    Write-Host "✓ Protected route accessible" -ForegroundColor Green
    Write-Host "  Router count: $($response.Count)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Failed to access protected route" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 6: Vouchers Endpoint
Write-Host "6. Testing vouchers endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/vouchers" -Method GET -Headers $headers
    Write-Host "✓ Vouchers endpoint accessible" -ForegroundColor Green
    Write-Host "  Voucher count: $($response.Count)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Failed to access vouchers" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
}
Write-Host ""

# Test 7: Profile Endpoint
Write-Host "7. Testing profile endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/profile" -Method GET -Headers $headers
    Write-Host "✓ Profile endpoint accessible" -ForegroundColor Green
    Write-Host "  Name: $($response.name)" -ForegroundColor Gray
    Write-Host "  Email: $($response.email)" -ForegroundColor Gray
    Write-Host "  Role: $($response.role)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Failed to get profile" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Backend is Ready for Mobile Testing!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Test Credentials for Mobile App:" -ForegroundColor Yellow
Write-Host "  Email: $testEmail" -ForegroundColor White
Write-Host "  Password: $testPassword" -ForegroundColor White
Write-Host ""
Write-Host "Mobile App Configuration:" -ForegroundColor Yellow
Write-Host "  Update app_constants.dart:" -ForegroundColor White
Write-Host "  static const String apiBaseUrl = 'http://192.168.1.227:3001';" -ForegroundColor Gray
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Update apiBaseUrl in app_constants.dart with your PC's IP" -ForegroundColor White
Write-Host "  2. Run: flutter run" -ForegroundColor White
Write-Host "  3. Use the test credentials above to login" -ForegroundColor White
Write-Host "  4. Follow the mobile_testing_checklist.md" -ForegroundColor White
Write-Host ""

# Save credentials to file for reference
$credentialsFile = "test-credentials.txt"
@"
Mobile App Test Credentials
Generated: $(Get-Date)

Email: $testEmail
Password: $testPassword
User ID: $userId

Backend URL: http://192.168.1.227:3001
Access Token: $accessToken

Use these credentials to test the mobile app.
"@ | Out-File -FilePath $credentialsFile -Encoding UTF8

Write-Host "Credentials saved to: $credentialsFile" -ForegroundColor Gray
