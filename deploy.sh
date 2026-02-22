#!/usr/bin/env bash
set -euo pipefail

# ============================================
# Wassal — VPS Deployment Script
# ============================================
#
# Prerequisites (run once on a fresh Ubuntu 24.04 VPS):
#
#   # Install Docker
#   sudo apt update && sudo apt install -y docker.io docker-compose-plugin
#   sudo systemctl enable --now docker
#   sudo usermod -aG docker $USER   # then log out & back in
#
#   # Open firewall
#   sudo ufw allow 80/tcp
#   sudo ufw allow 443/tcp
#   sudo ufw allow 1812/udp
#   sudo ufw allow 1813/udp
#   sudo ufw enable
#
#   # Clone the repo
#   git clone <your-repo-url> ~/wassal && cd ~/wassal
#   cp .env.example .env
#   nano .env   # fill in real values
#
# Usage:
#   ./deploy.sh          — first-time deploy (obtains SSL cert)
#   ./deploy.sh update   — pull latest code and rebuild
# ============================================

COMPOSE="docker compose -f docker-compose.prod.yml"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# ---- Load .env ----
if [ ! -f .env ]; then
    echo "ERROR: .env file not found. Copy .env.example to .env and fill in your values."
    exit 1
fi

set -a
source .env
set +a

# Validate required vars
for var in DOMAIN CERTBOT_EMAIL DB_PASSWORD JWT_SECRET JWT_REFRESH_SECRET ENCRYPTION_KEY RADIUS_SERVER_IP; do
    if [ -z "${!var:-}" ]; then
        echo "ERROR: $var is not set in .env"
        exit 1
    fi
done

# ---- Generate nginx.conf from template ----
generate_nginx_conf() {
    sed "s/__DOMAIN__/${DOMAIN}/g" nginx/nginx.conf.template > nginx/nginx.conf
    echo "Generated nginx/nginx.conf for domain: ${DOMAIN}"
}

# ---- UPDATE mode: pull & rebuild ----
if [ "${1:-}" = "update" ]; then
    echo "==> Pulling latest code..."
    git pull

    generate_nginx_conf

    echo "==> Rebuilding and restarting containers..."
    $COMPOSE up -d --build

    echo "==> Done. Reloading nginx to pick up any config changes..."
    docker exec wassal-nginx nginx -s reload 2>/dev/null || true

    echo ""
    echo "Update complete."
    echo "  Dashboard: https://admin.${DOMAIN}"
    echo "  API:       https://api.${DOMAIN}"
    exit 0
fi

# ---- FIRST-TIME DEPLOY ----

echo "============================================"
echo "  Wassal — First-Time Deployment"
echo "  Domain:    ${DOMAIN}"
echo "  Admin:     admin.${DOMAIN}"
echo "  API:       api.${DOMAIN}"
echo "============================================"
echo ""

# Step 1: Start with HTTP-only nginx (for Certbot challenge)
echo "==> Step 1/4: Starting services with HTTP-only nginx..."
cp nginx/nginx-init.conf nginx/nginx.conf
$COMPOSE up -d --build

echo "==> Waiting for services to be ready..."
sleep 10

# Step 2: Obtain SSL certificate
echo "==> Step 2/4: Obtaining SSL certificate from Let's Encrypt..."
docker compose -f docker-compose.prod.yml run --rm --entrypoint "" certbot \
    certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email "${CERTBOT_EMAIL}" \
    --agree-tos \
    --no-eff-email \
    -d "${DOMAIN}" \
    -d "admin.${DOMAIN}" \
    -d "api.${DOMAIN}"

# Step 3: Switch to full HTTPS nginx config
echo "==> Step 3/4: Switching to HTTPS nginx config..."
generate_nginx_conf

# Step 4: Reload nginx with SSL
echo "==> Step 4/4: Reloading nginx with SSL..."
docker exec wassal-nginx nginx -s reload

echo ""
echo "============================================"
echo "  Deployment complete!"
echo ""
echo "  Dashboard:  https://admin.${DOMAIN}"
echo "  API:        https://api.${DOMAIN}"
echo "  Swagger:    https://api.${DOMAIN}/api/docs"
echo ""
echo "  RADIUS:     ${RADIUS_SERVER_IP}:1812/udp"
echo ""
echo "  To update later:  ./deploy.sh update"
echo "============================================"
