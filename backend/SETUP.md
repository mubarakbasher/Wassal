# Setup Instructions

## Prerequisites

Before running the application, ensure you have:

1. **PostgreSQL** installed and running
2. **Node.js** v18+ installed
3. **npm** v9+ installed

## Step-by-Step Setup

### 1. Install PostgreSQL Database

#### Option A: Local PostgreSQL Installation

```bash
# Windows (using Chocolatey)
choco install postgresql

# Or download from: https://www.postgresql.org/download/windows/
```

#### Option B: Docker PostgreSQL (Recommended)

```bash
docker run --name mikrotik-postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=mikrotik_hotspot \
  -p 5432:5432 \
  -d postgres:14
```

### 2. Create Database

If using local PostgreSQL:

```bash
# Open PowerShell and run:
psql -U postgres

# In psql prompt:
CREATE DATABASE mikrotik_hotspot;
\q
```

### 3. Install Dependencies

```bash
cd backend
npm install
```

### 4. Generate Prisma Client

This is **REQUIRED** before running the application:

```bash
npx prisma generate
```

### 5. Run Database Migrations

```bash
npx prisma migrate dev --name init
```

This will create all the database tables based on the schema.

### 6. (Optional) View Database

```bash
npx prisma studio
```

This opens a web interface at `http://localhost:5555` to view your database.

### 7. Start the Development Server

```bash
npm run start:dev
```

The API will be available at `http://localhost:3001` (default port, configurable in `.env`)

> **Swagger API Docs** are available at `http://localhost:3001/api/docs`

## Testing the API

### 1. Register a User

```bash
curl -X POST http://localhost:3001/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"admin@example.com\",\"password\":\"SecurePass123\",\"name\":\"Admin User\",\"role\":\"ADMIN\"}"
```

### 2. Login

```bash
curl -X POST http://localhost:3001/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"admin@example.com\",\"password\":\"SecurePass123\"}"
```

Save the `accessToken` from the response.

### 3. Add a Router

```bash
curl -X POST http://localhost:3001/routers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d "{\"name\":\"Main Router\",\"ipAddress\":\"192.168.88.1\",\"username\":\"admin\",\"password\":\"routerpass\",\"description\":\"Main office router\"}"
```

### 4. List Routers

```bash
curl -X GET http://localhost:3001/routers \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### 5. Check Router Health

```bash
curl -X GET http://localhost:3001/routers/ROUTER_ID/health \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## Troubleshooting

### Error: "Cannot find module '@prisma/client'"

**Solution**: Run `npx prisma generate`

### Error: "Can't reach database server"

**Solution**: 
- Check if PostgreSQL is running
- Verify DATABASE_URL in `.env` file
- Test connection: `psql -U postgres -d mikrotik_hotspot`

### Error: "Table does not exist"

**Solution**: Run `npx prisma migrate dev --name init`

### 8. Seed Admin User (Required for Admin Dashboard)

```bash
npx ts-node prisma/seed-admin.ts
```

This creates a default admin account: `admin@wassal.com` / `password123`

## Next Steps

After successful setup:

1. ✅ Test authentication endpoints
2. ✅ Add a test router (requires actual MikroTik router or simulator)
3. ✅ Voucher system (generation, printing, activation)
4. ✅ Mobile application
5. ✅ Admin dashboard

## MikroTik Router Setup

To connect a real MikroTik router:

1. Enable API on the router:
   ```
   /ip service enable api
   /ip service set api port=8728
   ```

2. Create an API user:
   ```
   /user add name=apiuser password=apipass group=full
   ```

3. Ensure the router is accessible from your development machine

4. Add the router through the API using the credentials above
