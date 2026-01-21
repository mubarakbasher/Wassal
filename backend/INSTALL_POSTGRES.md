# PostgreSQL Installation Guide for Windows

## Option 1: Install PostgreSQL (Recommended for Production)

### Step 1: Download PostgreSQL
1. Go to: https://www.postgresql.org/download/windows/
2. Download the **PostgreSQL 14** or **PostgreSQL 15** installer
3. Run the installer

### Step 2: Installation Settings
- **Port**: Keep default `5432`
- **Password**: Set a password for the `postgres` user (remember this!)
- **Locale**: Keep default

### Step 3: After Installation
Open PowerShell as Administrator and verify:
```powershell
psql --version
```

### Step 4: Create Database
```powershell
# Connect to PostgreSQL
psql -U postgres

# In psql prompt, create database:
CREATE DATABASE mikrotik_hotspot;

# Exit
\q
```

### Step 5: Update .env File
Update the `DATABASE_URL` in your `.env` file:
```
DATABASE_URL="postgresql://postgres:YOUR_PASSWORD@localhost:5432/mikrotik_hotspot?schema=public"
```

Replace `YOUR_PASSWORD` with the password you set during installation.

---

## Option 2: Install Docker Desktop (Easier, Recommended for Development)

### Step 1: Download Docker Desktop
1. Go to: https://www.docker.com/products/docker-desktop/
2. Download Docker Desktop for Windows
3. Install and restart your computer

### Step 2: Start Docker Desktop
- Open Docker Desktop application
- Wait for it to start (you'll see the whale icon in system tray)

### Step 3: Run PostgreSQL Container
Open PowerShell and run:
```powershell
docker run --name mikrotik-postgres `
  -e POSTGRES_PASSWORD=postgres `
  -e POSTGRES_DB=mikrotik_hotspot `
  -p 5432:5432 `
  -d postgres:14
```

### Step 4: Verify Container is Running
```powershell
docker ps
```

You should see `mikrotik-postgres` in the list.

### Step 5: .env File is Already Configured
The default `.env` file is already set up for Docker:
```
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/mikrotik_hotspot?schema=public"
```

---

## After PostgreSQL is Ready

Once you have PostgreSQL installed (either option), run these commands:

### 1. Generate Prisma Client
```powershell
cd backend
npx prisma generate
```

This will generate the Prisma Client with all database types.

### 2. Run Database Migrations
```powershell
npx prisma migrate dev --name init
```

This will create all the database tables.

### 3. Verify Database
```powershell
npx prisma studio
```

This opens a web interface at http://localhost:5555 to view your database.

### 4. Start the Server
```powershell
npm run start:dev
```

---

## Quick Comparison

| Feature | PostgreSQL Native | Docker |
|---------|------------------|--------|
| Installation | ~200MB, requires restart | ~1GB, no restart |
| Setup Time | 10-15 minutes | 5 minutes |
| Performance | Faster | Slightly slower |
| Ease of Use | Medium | Easy |
| Best For | Production | Development |

---

## Troubleshooting

### Error: "Can't reach database server"
- **PostgreSQL Native**: Check if PostgreSQL service is running in Windows Services
- **Docker**: Check if Docker Desktop is running and container is started

### Error: "password authentication failed"
- Check your password in the `.env` file
- Make sure it matches the password you set during installation

### Error: "port 5432 is already in use"
- Another PostgreSQL instance is running
- Stop it or use a different port

---

## Next Steps After Database Setup

1. ✅ Generate Prisma Client
2. ✅ Run migrations
3. ✅ Start the server
4. Test the API endpoints
5. Begin mobile app development

---

## Need Help?

If you encounter any issues:
1. Check the error message carefully
2. Verify PostgreSQL is running
3. Check the `.env` file configuration
4. Try restarting PostgreSQL/Docker
