#!/usr/bin/env bash
# ============================================
# Wassal — WireGuard Peer Sync Script
# ============================================
# Reads peer config files written by the backend and applies
# them to the live wg0 interface. Triggered by systemd path unit
# watching the .trigger file.
set -euo pipefail

PEERS_DIR="/opt/wassal/wireguard/peers"
WG_INTERFACE="wg0"
WG_CONF="/etc/wireguard/${WG_INTERFACE}.conf"

if [ ! -d "$PEERS_DIR" ]; then
    echo "Peers directory not found: $PEERS_DIR"
    exit 0
fi

# Build a temporary config from the base config + all peer files
TMPCONF=$(mktemp)

# Copy the [Interface] section from the existing config
awk '/^\[Peer\]/{exit} {print}' "$WG_CONF" > "$TMPCONF"

# Append all peer configs
for peer_file in "$PEERS_DIR"/*.conf; do
    [ -f "$peer_file" ] || continue
    echo "" >> "$TMPCONF"
    cat "$peer_file" >> "$TMPCONF"
done

# Strip wg-quick directives (Address, DNS, PostUp, PostDown, SaveConfig) and apply
wg syncconf "$WG_INTERFACE" <(grep -v "^\s*\(Address\|DNS\|PostUp\|PostDown\|SaveConfig\|Table\|PreUp\|PreDown\|MTU\)\s*=" "$TMPCONF")

rm -f "$TMPCONF"

echo "[$(date)] WireGuard peers synced successfully"
