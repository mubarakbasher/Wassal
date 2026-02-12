#!/bin/bash
exec > /tmp/radius-debug.txt 2>&1

echo "=== Inserting test user ==="
PGPASSWORD=postgres psql -h localhost -U postgres -d mikrotik_hotspot -c "DELETE FROM radcheck WHERE username='testuser';"
PGPASSWORD=postgres psql -h localhost -U postgres -d mikrotik_hotspot -c "INSERT INTO radcheck (username, attribute, op, value) VALUES ('testuser', 'Cleartext-Password', ':=', 'testpass');"

echo "=== Verifying ==="
PGPASSWORD=postgres psql -h localhost -U postgres -d mikrotik_hotspot -c "SELECT * FROM radcheck WHERE username='testuser';"

echo ""
echo "=== Running radtest ==="
radtest testuser testpass 127.0.0.1 0 testing123 2>&1

echo ""
echo "=== FreeRADIUS request log ==="
tail -40 /tmp/freeradius-run.log
