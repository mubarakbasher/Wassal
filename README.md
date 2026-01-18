# MikroTik Hotspot Management System

Cloud-based platform for centralized remote management of MikroTik Hotspot routers.

## Project Structure

```
Wassal/
├── backend/          # NestJS Backend API
└── mobile/           # Flutter Mobile Application (Coming Soon)
```

## Features

- 🔐 Secure user authentication and authorization
- 🌐 Multi-router management
- 🎫 Automated voucher generation (time-based & data-based)
- 📊 Real-time session monitoring
- 💰 Sales tracking and reporting
- 📈 Analytics and insights
- 📱 Cross-platform mobile app

## Quick Start

### Backend Setup

```bash
cd backend
npm install
npx prisma migrate dev
npm run start:dev
```

See [backend/README.md](backend/README.md) for detailed instructions.

### Mobile App Setup

Coming soon...

## Technology Stack

### Backend
- NestJS + TypeScript
- PostgreSQL + Prisma ORM
- JWT Authentication
- node-routeros (MikroTik API)

### Mobile
- Flutter
- Bloc State Management
- Dio HTTP Client

## Documentation

- [Backend Documentation](backend/README.md)
- [API Documentation](backend/API.md) (Coming Soon)
- [Mobile App Documentation](mobile/README.md) (Coming Soon)

## License

[Your License Here]
