# Testing Guide - MikroTik Hotspot Management System

## 🧪 Testing Your Application

This guide will walk you through testing both the backend API and the Flutter mobile app.

---

## 1️⃣ Backend API Testing

### Prerequisites
- ✅ Backend server running on `http://localhost:3000`
- ✅ PostgreSQL database connected
- ✅ PowerShell terminal

### Quick Test Commands

#### **Test 1: User Registration**
```powershell
$registerBody = @{
    email = "test@example.com"
    password = "Test123456"
    name = "Test User"
    role = "OPERATOR"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:3000/auth/register" -Method POST -Headers @{"Content-Type"="application/json"} -Body $registerBody

# Save the token
$token = $response.accessToken
Write-Host "✓ Registration successful! Token: $($token.Substring(0,20))..."
```

#### **Test 2: User Login**
```powershell
$loginBody = @{
    email = "test@example.com"
    password = "Test123456"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:3000/auth/login" -Method POST -Headers @{"Content-Type"="application/json"} -Body $loginBody

$token = $response.accessToken
Write-Host "✓ Login successful!"
```

#### **Test 3: Get User Profile**
```powershell
$profile = Invoke-RestMethod -Uri "http://localhost:3000/auth/profile" -Headers @{"Authorization"="Bearer $token"}

Write-Host "User: $($profile.name) ($($profile.email))"
Write-Host "Role: $($profile.role)"
```

#### **Test 4: Add a Router**
```powershell
$routerBody = @{
    name = "Test Router"
    ipAddress = "192.168.88.1"
    apiPort = 8728
    username = "admin"
    password = "admin123"
} | ConvertTo-Json

$router = Invoke-RestMethod -Uri "http://localhost:3000/routers" -Method POST -Headers @{"Authorization"="Bearer $token"; "Content-Type"="application/json"} -Body $routerBody

Write-Host "✓ Router added: $($router.name)"
```

#### **Test 5: List Routers**
```powershell
$routers = Invoke-RestMethod -Uri "http://localhost:3000/routers" -Headers @{"Authorization"="Bearer $token"}

Write-Host "Total routers: $($routers.Count)"
$routers | ForEach-Object { Write-Host "  - $($_.name) ($($_.ipAddress)) - Status: $($_.status)" }
```

#### **Test 6: Generate Vouchers**
```powershell
# First, get a router ID
$routerId = $routers[0].id

$voucherBody = @{
    routerId = $routerId
    planType = "TIME_BASED"
    planName = "1 Hour Plan"
    duration = 3600
    price = 5.00
    quantity = 5
} | ConvertTo-Json

$vouchers = Invoke-RestMethod -Uri "http://localhost:3000/vouchers" -Method POST -Headers @{"Authorization"="Bearer $token"; "Content-Type"="application/json"} -Body $voucherBody

Write-Host "✓ Generated $($vouchers.Count) vouchers"
$vouchers | Select-Object -First 2 | ForEach-Object { Write-Host "  Username: $($_.username), Password: $($_.password)" }
```

#### **Test 7: List Vouchers**
```powershell
$allVouchers = Invoke-RestMethod -Uri "http://localhost:3000/vouchers" -Headers @{"Authorization"="Bearer $token"}

Write-Host "Total vouchers: $($allVouchers.Count)"
Write-Host "Unused: $(($allVouchers | Where-Object {$_.status -eq 'UNUSED'}).Count)"
Write-Host "Active: $(($allVouchers | Where-Object {$_.status -eq 'ACTIVE'}).Count)"
Write-Host "Sold: $(($allVouchers | Where-Object {$_.status -eq 'SOLD'}).Count)"
```

### Complete Test Script

Save this as `test-api.ps1`:

```powershell
Write-Host "=== MikroTik Hotspot API Testing ===" -ForegroundColor Cyan
Write-Host ""

# 1. Register
Write-Host "1. Testing Registration..." -ForegroundColor Yellow
$registerBody = @{ email = "test@example.com"; password = "Test123456"; name = "Test User"; role = "OPERATOR" } | ConvertTo-Json
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/auth/register" -Method POST -Headers @{"Content-Type"="application/json"} -Body $registerBody
    $token = $response.accessToken
    Write-Host "   ✓ Success" -ForegroundColor Green
} catch {
    Write-Host "   ℹ User exists, logging in instead..." -ForegroundColor Yellow
    $loginBody = @{ email = "test@example.com"; password = "Test123456" } | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "http://localhost:3000/auth/login" -Method POST -Headers @{"Content-Type"="application/json"} -Body $loginBody
    $token = $response.accessToken
}

# 2. Get Profile
Write-Host "2. Testing Get Profile..." -ForegroundColor Yellow
$profile = Invoke-RestMethod -Uri "http://localhost:3000/auth/profile" -Headers @{"Authorization"="Bearer $token"}
Write-Host "   ✓ User: $($profile.name)" -ForegroundColor Green

# 3. List Routers
Write-Host "3. Testing List Routers..." -ForegroundColor Yellow
$routers = Invoke-RestMethod -Uri "http://localhost:3000/routers" -Headers @{"Authorization"="Bearer $token"}
Write-Host "   ✓ Found $($routers.Count) routers" -ForegroundColor Green

# 4. List Vouchers
Write-Host "4. Testing List Vouchers..." -ForegroundColor Yellow
$vouchers = Invoke-RestMethod -Uri "http://localhost:3000/vouchers" -Headers @{"Authorization"="Bearer $token"}
Write-Host "   ✓ Found $($vouchers.Count) vouchers" -ForegroundColor Green

Write-Host ""
Write-Host "=== All Tests Passed! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Your token (save for manual testing):" -ForegroundColor Cyan
Write-Host $token
```

Run with: `./test-api.ps1`

---

## 2️⃣ Flutter Mobile App Testing

### Prerequisites
- Android Emulator OR Physical Android device connected
- Flutter SDK installed

### Step 1: Check Flutter Setup
```powershell
cd mobile
flutter doctor
```

### Step 2: Get Dependencies
```powershell
flutter pub get
```

### Step 3: Start Android Emulator
**Option A: Using Android Studio**
1. Open Android Studio
2. Tools → Device Manager
3. Create/Start an emulator

**Option B: Command Line**
```powershell
# List available emulators
emulator -list-avds

# Start an emulator
emulator -avd Pixel_4_API_30
```

### Step 4: Run the App
```powershell
# Make sure you're in the mobile directory
cd c:\Users\mubar\Desktop\Mikrotik\Wassal\mobile

# Run in debug mode
flutter run

# Or run with hot reload
flutter run --hot
```

### Step 5: Test the App Flow

**Test Login:**
1. App opens to Login screen
2. Enter: `test@example.com` / `Test123456`
3. Tap "Sign In"
4. Should navigate to Dashboard

**Test Registration:**
1. On Login screen, tap "Sign Up"
2. Fill in:
   - Name: Test User 2
   - Email: user2@example.com
   - Password: Password123
3. Tap "Create Account"
4. Should navigate to Dashboard

**Test Dashboard:**
1. See welcome message
2. View statistics cards
3. Click "Manage Routers" button

**Test Routers:**
1. Should see router list (or empty state)
2. Tap "+ Add Router" button
3. Fill in router details:
   - Name: Test Router
   - IP: 192.168.88.1
   - Port: 8728
   - Username: admin
   - Password: (your router password)
4. Tap "Add Router"
5. Router should appear in list

**Test Logout:**
1. Tap menu icon (3 dots) in app bar
2. Select "Logout"
3. Should return to Login screen

---

## 3️⃣ Troubleshooting

### Backend Issues

**Server not responding:**
```powershell
# Check if server is running
Get-Process -Name node

# Restart server
cd backend
npm run start:dev
```

**Database connection errors:**
```powershell
# Check Docker container
docker ps

# Restart container
docker restart mikrotik-postgres
```

### Mobile App Issues

**Build errors:**
```powershell
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

**Can't connect to backend:**
- If using emulator, backend URL should be `http://10.0.2.2:3000`
- If using physical device, use your PC's IP: `http://192.168.x.x:3000`

Update in: `mobile/lib/core/constants/app_constants.dart`

**Hot reload not working:**
```powershell
# Press 'r' in terminal for hot reload
# Press 'R' for hot restart
# Press 'q' to quit
```

---

## 4️⃣ Using Postman (Optional)

Download Postman: https://www.postman.com/downloads/

**Import these requests:**

1. POST `http://localhost:3000/auth/register`
2. POST `http://localhost:3000/auth/login`
3. GET `http://localhost:3000/auth/profile`
4. GET `http://localhost:3000/routers`
5. POST `http://localhost:3000/routers`
6. GET `http://localhost:3000/vouchers`
7. POST `http://localhost:3000/vouchers`

---

## 5️⃣ Expected Results

✅ Backend server responds to all endpoints
✅ Authentication works (register, login, profile)
✅ Routers can be added and listed
✅ Vouchers can be generated
✅ Mobile app connects successfully
✅ UI navigation works smoothly
✅ Forms validate correctly
✅ Error messages display properly

---

## 🎯 Next Steps After Testing

1. **If everything works**: Continue building voucher UI
2. **If issues found**: Debug and fix
3. **Ready for production**: Deploy to server

**Need help?** Check the logs:
- Backend: Terminal where `npm run start:dev` is running
- Mobile: Android Studio Logcat or `flutter logs`

Happy testing! 🚀
