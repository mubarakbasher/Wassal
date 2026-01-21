# Docker Setup Guide - Quick Start

## Step 1: Install Docker Desktop

1. **Download Docker Desktop**
   - Go to: https://www.docker.com/products/docker-desktop/
   - Click "Download for Windows"
   - Run the installer (DockerDesktop.exe)

2. **Installation Options**
   - ✅ Use WSL 2 instead of Hyper-V (recommended)
   - Follow the installation wizard
   - **Restart your computer when prompted**

3. **Start Docker Desktop**
   - Open Docker Desktop from Start Menu
   - Wait for the whale icon to appear in system tray
   - You'll see "Docker Desktop is running" notification

## Step 2: Verify Docker is Running

Open PowerShell and run:
```powershell
docker --version
```

You should see something like: `Docker version 24.x.x`

## Step 3: Start PostgreSQL Container

Run this command in PowerShell:
```powershell
docker run --name mikrotik-postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=mikrotik_hotspot -p 5432:5432 -d postgres:14
```

**What this does:**
- Creates a container named `mikrotik-postgres`
- Sets password to `postgres`
- Creates database `mikrotik_hotspot`
- Exposes port 5432
- Uses PostgreSQL 14

## Step 4: Verify Container is Running

```powershell
docker ps
```

You should see `mikrotik-postgres` in the list with status "Up".

## Step 5: Set Up Database

Now run the setup script:
```powershell
cd c:\Users\mubar\Desktop\Mikrotik\Wassal\backend
.\setup-database.bat
```

This will:
1. Generate Prisma Client
2. Run database migrations
3. Create all tables

## Done! 🎉

Your database is now ready. You can:

**Start the server:**
```powershell
npm run start:dev
```

**View the database:**
```powershell
npx prisma studio
```
Opens at http://localhost:5555

## Managing Your Docker Container

**Stop the container:**
```powershell
docker stop mikrotik-postgres
```

**Start the container:**
```powershell
docker start mikrotik-postgres
```

**Remove the container:**
```powershell
docker rm -f mikrotik-postgres
```

**View logs:**
```powershell
docker logs mikrotik-postgres
```

## Troubleshooting

**Error: "docker: command not found"**
- Docker Desktop is not installed or not running
- Restart Docker Desktop
- Restart your computer if just installed

**Error: "port 5432 is already in use"**
- Another PostgreSQL is running
- Stop it or use a different port:
  ```powershell
  docker run --name mikrotik-postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=mikrotik_hotspot -p 5433:5432 -d postgres:14
  ```
  Then update `.env`: `DATABASE_URL="postgresql://postgres:postgres@localhost:5433/mikrotik_hotspot"`

**Error: "Cannot connect to Docker daemon"**
- Open Docker Desktop application
- Wait for it to fully start
- Check the whale icon in system tray is green

## Next Steps

Once database setup is complete:
1. ✅ Test API endpoints (see `api_reference.md`)
2. ✅ Start building the mobile app
3. ✅ Deploy to production

---

**Quick Command Reference:**
```powershell
# Check Docker status
docker ps

# View all containers (including stopped)
docker ps -a

# View container logs
docker logs mikrotik-postgres

# Access PostgreSQL CLI
docker exec -it mikrotik-postgres psql -U postgres -d mikrotik_hotspot

# Backup database
docker exec mikrotik-postgres pg_dump -U postgres mikrotik_hotspot > backup.sql

# Restore database
docker exec -i mikrotik-postgres psql -U postgres mikrotik_hotspot < backup.sql
```
