# FreeRADIUS Configuration Guide for Wassal

## Prerequisites
- FreeRADIUS 3.x installed
- PostgreSQL database (same as backend)
- MikroTik RouterOS v6 or v7

---

## 1. Install FreeRADIUS (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install freeradius freeradius-postgresql freeradius-utils
```

## 2. Configure PostgreSQL Module

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

    # Use standard FreeRADIUS SQL queries
    # The tables (radcheck, radreply, etc.) are already created by Prisma migration
}
```

Enable the SQL module:
```bash
cd /etc/freeradius/3.0/mods-enabled
sudo ln -s ../mods-available/sql sql
```

## 3. Configure Sites

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

## 4. MikroTik Dictionary

The MikroTik vendor attributes dictionary should already be included with FreeRADIUS.
Verify it exists at `/etc/freeradius/3.0/dictionary.mikrotik` or `/usr/share/freeradius/dictionary.mikrotik`.

Key attributes used:
- `Mikrotik-Rate-Limit` — Speed limit (e.g., "2M/2M")
- `Mikrotik-Total-Limit` — Total bytes limit

## 5. Test FreeRADIUS

Start in debug mode first:
```bash
sudo freeradius -X
```

Test authentication with a voucher:
```bash
radtest <username> <password> localhost 0 testing123
```

Expected output for active voucher:
```
Received Access-Accept Id ... from 127.0.0.1:1812
    Mikrotik-Rate-Limit = "2M/2M"
    Session-Timeout = 3600
```

Expected output for expired voucher:
```
Received Access-Reject Id ... from 127.0.0.1:1812
```

## 6. Run as Service

```bash
sudo systemctl enable freeradius
sudo systemctl start freeradius
```

---

## MikroTik Router Configuration

### Via WinBox / Terminal (v6 & v7 compatible)

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
> record when you add a router through the Wassal app. You can find it in the 
> database or the router details in the admin panel.

### Via Wassal Backend API

The RADIUS secret is returned when you add a router via the API:
```json
{
    "id": "router-uuid",
    "name": "My Router",
    "ipAddress": "192.168.1.1",
    "radiusSecret": "abc123def456..."
}
```

Use this secret when configuring `/radius` on the MikroTik.

---

## Troubleshooting

| Problem | Check |
|---|---|
| Auth rejected for valid user | Verify `radcheck` table has the user with correct password |
| No speed limit applied | Verify `radreply` or `radgroupreply` has `Mikrotik-Rate-Limit` |
| Time not expiring | Verify `Expiration` attribute in `radcheck` |
| MikroTik can't reach RADIUS | Check firewall, verify `nas` table has the router IP |
| "Unknown client" in RADIUS log | Router IP not in `nas` table, or FreeRADIUS needs restart |
