# Test API Script for PowerShell

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "MikroTik Hotspot Management System" -ForegroundColor Cyan
Write-Host "API Testing Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Register Admin User
Write-Host "Test 1: Registering Admin User..." -ForegroundColor Yellow
$registerBody = @{
    email = "admin@example.com"
    password = "SecurePass123"
    name = "Admin User"
    role = "ADMIN"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "http://localhost:3000/auth/register" -Method POST -Headers @{"Content-Type"="application/json"} -Body $registerBody
    Write-Host "✓ Registration successful!" -ForegroundColor Green
    Write-Host "  User: $($registerResponse.user.email)" -ForegroundColor Gray
    Write-Host "  Role: $($registerResponse.user.role)" -ForegroundColor Gray
    Write-Host "  Token: $($registerResponse.accessToken.Substring(0,20))..." -ForegroundColor Gray
    Write-Host ""
} catch {
    if ($_.Exception.Response.StatusCode -eq 409) {
        Write-Host "ℹ User already exists, skipping registration" -ForegroundColor Yellow
        Write-Host ""
    } else {
        Write-Host "✗ Registration failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        exit 1
    }
}

# Test 2: Login
Write-Host "Test 2: Logging in..." -ForegroundColor Yellow
$loginBody = @{
    email = "admin@example.com"
    password = "SecurePass123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:3000/auth/login" -Method POST -Headers @{"Content-Type"="application/json"} -Body $loginBody
    $token = $loginResponse.accessToken
    Write-Host "✓ Login successful!" -ForegroundColor Green
    Write-Host "  User: $($loginResponse.user.email)" -ForegroundColor Gray
    Write-Host "  Token: $($token.Substring(0,20))..." -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "✗ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    exit 1
}

# Test 3: Get Profile
Write-Host "Test 3: Getting user profile..." -ForegroundColor Yellow
try {
    $profileResponse = Invoke-RestMethod -Uri "http://localhost:3000/auth/profile" -Method GET -Headers @{"Authorization"="Bearer $token"}
    Write-Host "✓ Profile retrieved successfully!" -ForegroundColor Green
    Write-Host "  Name: $($profileResponse.name)" -ForegroundColor Gray
    Write-Host "  Email: $($profileResponse.email)" -ForegroundColor Gray
    Write-Host "  Role: $($profileResponse.role)" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "✗ Failed to get profile: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    exit 1
}

# Test 4: Create User (Admin Only)
Write-Host "Test 4: Creating new user (Admin Endpoint)..." -ForegroundColor Yellow
$createUserBody = @{
    email = "operator@example.com"
    password = "OperatorPass123"
    name = "Test Operator"
    role = "OPERATOR"
} | ConvertTo-Json

$createdUserId = $null

try {
    $createUserResponse = Invoke-RestMethod -Uri "http://localhost:3000/users" -Method POST -Headers @{"Authorization"="Bearer $token"; "Content-Type"="application/json"} -Body $createUserBody
    $createdUserId = $createUserResponse.id
    Write-Host "✓ User created successfully!" -ForegroundColor Green
    Write-Host "  ID: $createdUserId" -ForegroundColor Gray
    Write-Host "  Email: $($createUserResponse.email)" -ForegroundColor Gray
    Write-Host "  Role: $($createUserResponse.role)" -ForegroundColor Gray
    Write-Host ""
} catch {
     if ($_.Exception.Response.StatusCode -eq 409) {
        Write-Host "ℹ User already exists, attempting to find it..." -ForegroundColor Yellow
        try {
            # Basic retry to find the user if we can't create it, so we can test other endpoints
            $users = Invoke-RestMethod -Uri "http://localhost:3000/users" -Method GET -Headers @{"Authorization"="Bearer $token"}
            $existingUser = $users | Where-Object { $_.email -eq "operator@example.com" }
            if ($existingUser) {
                 $createdUserId = $existingUser.id
                 Write-Host "✓ Found existing user for testing." -ForegroundColor Green
                 Write-Host "  ID: $createdUserId" -ForegroundColor Gray
            } else {
                 Write-Host "✗ Could not find existing user." -ForegroundColor Red
            }
        } catch {
             Write-Host "✗ Failed to list users to find existing one." -ForegroundColor Red
        }
        Write-Host ""
    } else {
        Write-Host "✗ Failed to create user: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
    }
}

if ($createdUserId) {
    # Test 5: List Users
    Write-Host "Test 5: Listing all users..." -ForegroundColor Yellow
    try {
        $usersResponse = Invoke-RestMethod -Uri "http://localhost:3000/users" -Method GET -Headers @{"Authorization"="Bearer $token"}
        Write-Host "✓ Users listed successfully!" -ForegroundColor Green
        Write-Host "  Count: $($usersResponse.Count)" -ForegroundColor Gray
        $usersResponse | Format-Table id, email, role, name -AutoSize | Out-String | Write-Host
        Write-Host ""
    } catch {
        Write-Host "✗ Failed to list users: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
    }

    # Test 6: Get Specific User
    Write-Host "Test 6: Getting specific user details..." -ForegroundColor Yellow
    try {
        $userResponse = Invoke-RestMethod -Uri "http://localhost:3000/users/$createdUserId" -Method GET -Headers @{"Authorization"="Bearer $token"}
        Write-Host "✓ User details retrieved successfully!" -ForegroundColor Green
        Write-Host "  Email: $($userResponse.email)" -ForegroundColor Gray
        Write-Host ""
    } catch {
        Write-Host "✗ Failed to get user: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
    }

    # Test 7: Update User
    Write-Host "Test 7: Updating user..." -ForegroundColor Yellow
    $updateBody = @{
        name = "Updated Operator Name"
    } | ConvertTo-Json

    try {
        $updateResponse = Invoke-RestMethod -Uri "http://localhost:3000/users/$createdUserId" -Method PATCH -Headers @{"Authorization"="Bearer $token"; "Content-Type"="application/json"} -Body $updateBody
        Write-Host "✓ User updated successfully!" -ForegroundColor Green
        Write-Host "  New Name: $($updateResponse.name)" -ForegroundColor Gray
        Write-Host ""
    } catch {
        Write-Host "✗ Failed to update user: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
    }

    # Test 8: Delete User
    Write-Host "Test 8: Deleting user..." -ForegroundColor Yellow
    try {
        $deleteResponse = Invoke-RestMethod -Uri "http://localhost:3000/users/$createdUserId" -Method DELETE -Headers @{"Authorization"="Bearer $token"}
        Write-Host "✓ User deleted successfully!" -ForegroundColor Green
        Write-Host ""
    } catch {
        Write-Host "✗ Failed to delete user: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Tests Completed" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
