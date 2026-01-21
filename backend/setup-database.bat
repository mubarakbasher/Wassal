@echo off
echo ========================================
echo MikroTik Hotspot Management System
echo Database Setup Script
echo ========================================
echo.

echo Step 1: Checking Node.js...
node --version
if %errorlevel% neq 0 (
    echo ERROR: Node.js is not installed!
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)
echo ✓ Node.js is installed
echo.

echo Step 2: Checking npm packages...
if not exist "node_modules" (
    echo Installing dependencies...
    call npm install
    if %errorlevel% neq 0 (
        echo ERROR: Failed to install dependencies!
        pause
        exit /b 1
    )
)
echo ✓ Dependencies installed
echo.

echo Step 3: Generating Prisma Client...
call npx prisma generate
if %errorlevel% neq 0 (
    echo ERROR: Failed to generate Prisma Client!
    echo.
    echo Possible reasons:
    echo - PostgreSQL is not installed or not running
    echo - DATABASE_URL in .env file is incorrect
    echo - Network connection issue
    echo.
    echo Please check INSTALL_POSTGRES.md for setup instructions
    pause
    exit /b 1
)
echo ✓ Prisma Client generated
echo.

echo Step 4: Running database migrations...
call npx prisma migrate dev --name init
if %errorlevel% neq 0 (
    echo ERROR: Failed to run migrations!
    echo.
    echo Please check:
    echo - PostgreSQL is running
    echo - DATABASE_URL in .env is correct
    echo - Database 'mikrotik_hotspot' exists
    pause
    exit /b 1
)
echo ✓ Database migrations completed
echo.

echo ========================================
echo Database setup completed successfully!
echo ========================================
echo.
echo Next steps:
echo 1. Start the server: npm run start:dev
echo 2. Test the API: http://localhost:3000
echo 3. View database: npx prisma studio
echo.
pause
