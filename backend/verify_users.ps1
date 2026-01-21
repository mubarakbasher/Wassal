# User Management Verification Script

$baseUrl = "http://localhost:3000"
$adminEmail = "admin@example.com"
$adminPassword = "SecurePass123"

Write-Host "1. login as Admin" -ForegroundColor Yellow
$loginBody = @{ email = $adminEmail; password = $adminPassword } | ConvertTo-Json
try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Headers @{"Content-Type"="application/json"} -Body $loginBody
    $token = $loginResponse.accessToken
    Write-Host "Login Success. Token acquired." -ForegroundColor Green
} catch {
    Write-Host "Login Failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Write-Host "2. Create a new Operator" -ForegroundColor Yellow
$newEmail = "op_$(Get-Random)@test.com"
$createBody = @{
    email = $newEmail
    password = "Password123"
    name = "Test Operator"
    role = "OPERATOR"
} | ConvertTo-Json

try {
    $createdUser = Invoke-RestMethod -Uri "$baseUrl/users" -Method POST -Headers $headers -Body $createBody
    $userId = $createdUser.id
    Write-Host "User Created: $($createdUser.email) (ID: $userId)" -ForegroundColor Green
} catch {
    Write-Host "Create User Failed: $($_.Exception.Message)" -ForegroundColor Red
    # Continue anyway to test list? No, we need ID.
    exit 1
}

Write-Host "3. List all users" -ForegroundColor Yellow
try {
    $users = Invoke-RestMethod -Uri "$baseUrl/users" -Method GET -Headers $headers
    Write-Host "Found $($users.Count) users." -ForegroundColor Green
    $users | Format-Table email, role, name -AutoSize
} catch {
    Write-Host "List Users Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "4. Get the created user" -ForegroundColor Yellow
try {
    $user = Invoke-RestMethod -Uri "$baseUrl/users/$userId" -Method GET -Headers $headers
    if ($user.email -eq $newEmail) {
        Write-Host "Verified User Details: $($user.email)" -ForegroundColor Green
    } else {
        Write-Host "Mismatch in user details" -ForegroundColor Red
    }
} catch {
    Write-Host "Get User Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "5. Update the user" -ForegroundColor Yellow
$updateBody = @{ name = "Updated Name" } | ConvertTo-Json
try {
    $updated = Invoke-RestMethod -Uri "$baseUrl/users/$userId" -Method PATCH -Headers $headers -Body $updateBody
    if ($updated.name -eq "Updated Name") {
         Write-Host "Update Success: $($updated.name)" -ForegroundColor Green
    } else {
         Write-Host "Update mismatch" -ForegroundColor Red
    }
} catch {
    Write-Host "Update User Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "6. Delete the user" -ForegroundColor Yellow
try {
    Invoke-RestMethod -Uri "$baseUrl/users/$userId" -Method DELETE -Headers $headers
    Write-Host "Delete Success" -ForegroundColor Green
} catch {
    Write-Host "Delete User Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Verification Complete" -ForegroundColor Cyan
