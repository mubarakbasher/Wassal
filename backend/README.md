# MikroTik Hotspot Management System - Backend

Cloud-based platform for centralized remote management of MikroTik Hotspot routers.

## Features

- 🔐 **Secure Authentication** - JWT-based authentication with role-based access control
- 🌐 **Router Management** - Register and monitor multiple MikroTik routers
- 🎫 **Voucher System** - Generate time-based and data-based hotspot vouchers
- 📊 **Real-time Monitoring** - Track active sessions and bandwidth usage
- 💰 **Sales Management** - Record and analyze voucher sales
- 📈 **Analytics** - Comprehensive reports and insights

## Tech Stack

- **Framework**: NestJS (Node.js + TypeScript)
- **Database**: PostgreSQL
- **ORM**: Prisma
- **Authentication**: JWT + Passport
- **MikroTik Integration**: node-routeros

## Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** (v18 or higher)
- **npm** (v9 or higher)
- **PostgreSQL** (v14 or higher)
- **Git**

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd Wassal/backend
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Configure Environment Variables

The `.env` file has been created with default values. Update the following:

```env
# Database Configuration
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/mikrotik_hotspot?schema=public"

# JWT Configuration
JWT_SECRET="your-super-secret-jwt-key-change-this-in-production"
JWT_EXPIRATION="1d"
REFRESH_TOKEN_EXPIRATION="7d"

# Server Configuration
PORT=3000
NODE_ENV="development"
```

**Important**: Change the `JWT_SECRET` to a strong random string in production!

### 4. Set Up PostgreSQL Database

#### Option A: Local PostgreSQL

1. Install PostgreSQL if not already installed
2. Create a new database:

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE mikrotik_hotspot;

# Exit
\q
```

#### Option B: Docker PostgreSQL

```bash
docker run --name mikrotik-postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=mikrotik_hotspot \
  -p 5432:5432 \
  -d postgres:14
```

### 5. Run Database Migrations

```bash
# Generate Prisma Client
npx prisma generate

# Run migrations to create tables
npx prisma migrate dev --name init

# (Optional) Open Prisma Studio to view database
npx prisma studio
```

### 6. Start the Development Server

```bash
npm run start:dev
```

The API will be available at `http://localhost:3000`

## Database Schema

The system includes the following models:

- **User** - System users with role-based access (Admin, Operator, Reseller)
- **Router** - MikroTik routers registered in the system
- **HotspotProfile** - Hotspot profiles with rate limits and timeouts
- **Voucher** - Generated vouchers with time/data-based plans
- **Session** - Active and historical user sessions
- **Sale** - Voucher sales records
- **ActivityLog** - Audit trail of system activities

## API Endpoints

### Authentication

```
POST   /auth/register    - Register new user
POST   /auth/login       - User login
GET    /auth/profile     - Get user profile (protected)
```

### Example: Register a User

```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "SecurePass123",
    "name": "Admin User",
    "role": "ADMIN"
  }'
```

### Example: Login

```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "SecurePass123"
  }'
```

## Project Structure

```
backend/
├── prisma/
│   └── schema.prisma          # Database schema
├── src/
│   ├── auth/                  # Authentication module
│   │   ├── decorators/        # Custom decorators
│   │   ├── dto/               # Data transfer objects
│   │   ├── guards/            # Auth guards
│   │   ├── strategies/        # Passport strategies
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   └── auth.module.ts
│   ├── prisma/                # Prisma service
│   │   ├── prisma.service.ts
│   │   └── prisma.module.ts
│   ├── app.module.ts          # Root module
│   └── main.ts                # Application entry point
├── .env                       # Environment variables
└── package.json               # Dependencies
```

## Development Commands

```bash
# Start development server with hot reload
npm run start:dev

# Build for production
npm run build

# Start production server
npm run start:prod

# Run tests
npm run test

# Run e2e tests
npm run test:e2e

# Format code
npm run format

# Lint code
npm run lint
```

## Prisma Commands

```bash
# Generate Prisma Client
npx prisma generate

# Create a migration
npx prisma migrate dev --name migration_name

# Apply migrations
npx prisma migrate deploy

# Reset database (WARNING: deletes all data)
npx prisma migrate reset

# Open Prisma Studio (database GUI)
npx prisma studio
```

## Next Steps

1. ✅ Backend foundation complete
2. 🔄 Implement router management module
3. 🔄 Build MikroTik API integration
4. 🔄 Create voucher generation system
5. 🔄 Add monitoring and analytics
6. 🔄 Develop mobile application

## Security Considerations

- All passwords are hashed using bcrypt
- JWT tokens for stateless authentication
- Role-based access control (RBAC)
- Input validation using class-validator
- SQL injection protection via Prisma
- Environment variables for sensitive data

## MikroTik Router Requirements

To connect a MikroTik router to this system:

1. Enable MikroTik API (default port 8728)
2. Create an API user with appropriate permissions
3. Ensure the router has a static IP or DDNS
4. Configure VPN tunnel for secure communication (recommended)

## Support

For issues and questions, please refer to the project documentation or create an issue in the repository.

## License

[Your License Here]
