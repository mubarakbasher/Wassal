# FreeRADIUS Configuration Guide for Wassal

## Quick Start (Docker — Recommended)

The easiest way to run FreeRADIUS is via Docker Compose:

```bash
# 1. Copy environment template
cp .env.example .env

# 2. Edit .env — set RADIUS_SERVER_IP to your server's LAN IP
#    (the IP your MikroTik routers can reach)
nano .env

# 3. Start all services (PostgreSQL + FreeRADIUS + Backend)
docker-compose up -d

# 4. Run database migrations
cd backend && npx prisma migrate deploy
```

FreeRADIUS will automatically connect to PostgreSQL and read:
- **`radcheck`** — User credentials (populated when vouchers are created)
- **`radreply`** — Reply attributes like speed limits
- **`radusergroup`** / **`radgroupreply`** — Group-level profiles
- **`nas`** — NAS clients (populated when routers are added)
- **`radacct`** — Accounting data (written by FreeRADIUS on sessions)
- **`radpostauth`** — Authentication logs

### Test Authentication
```bash
# From the FreeRADIUS container:
docker exec wassal-freeradius radtest <username> <password> 127.0.0.1 0 testing123

# Expected for active voucher:
# Received Access-Accept with Mikrotik-Rate-Limit and Session-Timeout
```

---

## Manual Installation (Ubuntu/Debian)

### Prerequisites
- FreeRADIUS 3.x installed
- PostgreSQL database (same as backend)
- MikroTik RouterOS v6 or v7

### 1. Install FreeRADIUS

```bash
sudo apt update
sudo apt install freeradius freeradius-postgresql freeradius-utils
```

### 2. Configure PostgreSQL Module

Edit `/etc/freeradius/3.0/mods-available/sql`:

```ini
sql {
    driver = "rlm_sql_postgresql"
    dialect = "postgresql"

    server = "localhost"
    port = 5432
    login = "your_db_user"
    password = "your_db_password"
    
    radius_db = "your_database_name"

    # Read NAS clients from database
    read_clients = yes
    client_table = "nas"

    # The tables (radcheck, radreply, etc.) are already created by Prisma migration
}
```

Enable the SQL module:
```bash
cd /etc/freeradius/3.0/mods-enabled
sudo ln -s ../mods-available/sql sql
```

### 3. Configure Sites

Edit `/etc/freeradius/3.0/sites-enabled/default`:

In the `authorize` section, ensure `sql` is listed:
```
authorize {
    preprocess
    sql
}
```

In the `authenticate` section:
```
authenticate {
    Auth-Type PAP {
        pap
    }
    Auth-Type CHAP {
        chap
    }
    Auth-Type MS-CHAP {
        mschap
    }
}
```

In the `accounting` section:
```
accounting {
    sql
}
```

In the `post-auth` section:
```
post-auth {
    sql
    Post-Auth-Type REJECT {
        sql
    }
}
```

### 4. Test FreeRADIUS

Start in debug mode first:
```bash
sudo freeradius -X
```

Test authentication with a voucher:
```bash
radtest <username> <password> localhost 0 testing123
```

### 5. Run as Service

```bash
sudo systemctl enable freeradius
sudo systemctl start freeradius
```

---

## How the Integration Works

### Flow: Voucher Created → FreeRADIUS → MikroTik

```
┌──────────────────┐     ┌───────────────────┐     ┌──────────────────┐
│   Wassal App     │     │   FreeRADIUS       │     │   MikroTik       │
│                  │     │                    │     │   Router         │
│  Create Voucher  │     │                    │     │                  │
│  ─────────────►  │     │                    │     │                  │
│  Writes to:      │     │                    │     │                  │
│  • radcheck      │     │                    │     │                  │
│  • radusergroup  │     │                    │     │                  │
│  • radreply      │     │                    │     │                  │
│                  │     │                    │     │                  │
│  Add Router      │     │                    │     │                  │
│  ─────────────►  │     │                    │     │                  │
│  Writes to:      │     │                    │     │  Configured to   │
│  • nas table     │     │  Reads nas table   │     │  use RADIUS      │
│                  │     │                    │     │                  │
│                  │     │  User connects ◄───┤─────┤  Hotspot login   │
│                  │     │  to hotspot        │     │                  │
│                  │     │                    │     │                  │
│                  │     │  Checks radcheck   │     │                  │
│                  │     │  Returns Accept ───┤────►│  User gets       │
│                  │     │  with speed limit  │     │  internet access │
│                  │     │                    │     │                  │
│                  │     │  Writes radacct ───┤─    │                  │
│  Session Sync    │◄────┤──────────────────  │     │                  │
│  (every 5 min)   │     │                    │     │                  │
└──────────────────┘     └───────────────────┘     └──────────────────┘
```

### Backend RADIUS API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/radius/status` | RADIUS table counts and health |
| GET | `/radius/users` | List all RADIUS users |
| GET | `/radius/users/:username` | User details with attributes |
| GET | `/radius/online` | Currently online users |
| GET | `/radius/accounting/:username` | Session history |
| GET | `/radius/nas` | Registered NAS clients |

### Cron Jobs (Automatic)

| Job | Frequency | Action |
|-----|-----------|--------|
| Session Sync | Every 5 min | Syncs `radacct` → app `Session` table |
| Voucher Expiration | Every 1 min | Expires vouchers and removes RADIUS credentials |

---

## MikroTik Router Configuration

### Automatic (via Wassal App)
When you add a router through the app, RADIUS is configured automatically:
1. NAS entry created in database
2. RADIUS server added to the MikroTik router
3. Hotspot profile set to `use-radius=yes`

### Manual (via WinBox / Terminal)

```
# 1. Add RADIUS server
/radius add address=<FREERADIUS_SERVER_IP> secret=<RADIUS_SECRET> service=hotspot

# 2. Enable RADIUS for hotspot
/ip hotspot profile set default use-radius=yes

# 3. Set accounting
/ip hotspot profile set default accounting=yes

# 4. Optional: Set RADIUS as only authentication method
/ip hotspot profile set default login-by=http-chap
```

> **Note**: The `<RADIUS_SECRET>` is automatically generated and stored in the router
> record when you add a router through the Wassal app.

---

## MikroTik Dictionary

The MikroTik vendor attributes dictionary should already be included with FreeRADIUS.
Verify it exists at `/etc/freeradius/3.0/dictionary.mikrotik` or `/usr/share/freeradius/dictionary.mikrotik`.

Key attributes used:
- `Mikrotik-Rate-Limit` — Speed limit (e.g., "2M/2M")
- `Mikrotik-Total-Limit` — Total bytes limit

---

## Troubleshooting

| Problem | Check |
|---|---|
| Auth rejected for valid user | Verify `radcheck` table has the user with correct password |
| No speed limit applied | Verify `radreply` or `radgroupreply` has `Mikrotik-Rate-Limit` |
| Time not expiring | Verify `Expiration` attribute in `radcheck` |
| MikroTik can't reach RADIUS | Check firewall, verify `nas` table has the router IP |
| "Unknown client" in RADIUS log | Router IP not in `nas` table, or FreeRADIUS needs restart |
| Docker: FreeRADIUS can't connect to DB | Check `ENV_RADIUS_DB_*` env vars in docker-compose |
| Vouchers not expiring | Check that `RadiusSyncService` cron is running (see backend logs) |
