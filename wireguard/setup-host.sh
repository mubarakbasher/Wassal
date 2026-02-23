#!/usr/bin/env bash
# ============================================
# Wassal — WireGuard Host Setup (run once on VPS)
# ============================================
# Run this script as root on the VPS to set up WireGuard.
# After running, add WG_SERVER_PUBLIC_KEY and WG_SERVER_ENDPOINT
# to your .env file, then redeploy.
set -euo pipefail

echo "============================================"
echo "  Wassal — WireGuard Host Setup"
echo "============================================"

# 1. Install WireGuard
echo "==> Installing WireGuard..."
apt update && apt install -y wireguard

# 2. Generate server keys
echo "==> Generating server keys..."
mkdir -p /etc/wireguard
wg genkey | tee /etc/wireguard/server_private.key | wg pubkey > /etc/wireguard/server_public.key
chmod 600 /etc/wireguard/server_private.key

PRIVATE_KEY=$(cat /etc/wireguard/server_private.key)
PUBLIC_KEY=$(cat /etc/wireguard/server_public.key)

# 3. Detect primary network interface
PRIMARY_IF=$(ip route show default | awk '{print $5}' | head -1)
echo "==> Detected primary interface: $PRIMARY_IF"

# 4. Create WireGuard config
echo "==> Creating /etc/wireguard/wg0.conf..."
cat > /etc/wireguard/wg0.conf << EOF
[Interface]
PrivateKey = ${PRIVATE_KEY}
Address = 10.10.10.1/16
ListenPort = 51820
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o ${PRIMARY_IF} -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o ${PRIMARY_IF} -j MASQUERADE
EOF

chmod 600 /etc/wireguard/wg0.conf

# 5. Enable IP forwarding
echo "==> Enabling IP forwarding..."
sysctl -w net.ipv4.ip_forward=1
grep -q 'net.ipv4.ip_forward=1' /etc/sysctl.conf || echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf

# 6. Start WireGuard
echo "==> Starting WireGuard..."
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

# 7. Open firewall
echo "==> Opening firewall port 51820/udp..."
ufw allow 51820/udp || true

# 8. Set up peers directory
echo "==> Creating peers directory..."
mkdir -p /opt/wassal/wireguard/peers
touch /opt/wassal/wireguard/peers/.trigger

# 9. Install sync script and systemd units
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

cp "$SCRIPT_DIR/sync-peers.sh" /opt/wassal/wireguard/sync-peers.sh
chmod +x /opt/wassal/wireguard/sync-peers.sh

cp "$SCRIPT_DIR/wg-sync.path" /etc/systemd/system/wg-sync.path
cp "$SCRIPT_DIR/wg-sync.service" /etc/systemd/system/wg-sync.service

systemctl daemon-reload
systemctl enable wg-sync.path
systemctl start wg-sync.path

# Detect VPS public IP
VPS_IP=$(curl -s ifconfig.me || echo "YOUR_VPS_IP")

echo ""
echo "============================================"
echo "  WireGuard Setup Complete!"
echo ""
echo "  Server Public Key: ${PUBLIC_KEY}"
echo "  VPS IP:            ${VPS_IP}"
echo ""
echo "  Add these to your .env file:"
echo ""
echo "    WG_SERVER_PUBLIC_KEY=${PUBLIC_KEY}"
echo "    WG_SERVER_ENDPOINT=${VPS_IP}:51820"
echo ""
echo "  Then run: ./deploy.sh update"
echo "============================================"
