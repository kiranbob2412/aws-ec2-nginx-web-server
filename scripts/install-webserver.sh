#!/usr/bin/env bash

set -Eeuo pipefail

WEB_ROOT="/var/www/html"
PAGE_SOURCE="/tmp/index.html"

log() {
    echo "[INFO] $1"
}

error() {
    echo "[ERROR] $1" >&2
    exit 1
}

if [[ "$EUID" -ne 0 ]]; then
    error "Run this script with sudo."
fi

log "Updating package repository..."
apt-get update -y

log "Installing Nginx..."
apt-get install -y nginx curl

log "Checking Nginx installation..."
nginx -v

log "Enabling Nginx at boot..."
systemctl enable nginx

log "Starting Nginx..."
systemctl start nginx

if [[ -f "$PAGE_SOURCE" ]]; then
    log "Deploying custom landing page..."
    install -m 0644 "$PAGE_SOURCE" "$WEB_ROOT/index.html"
else
    error "Landing page not found at $PAGE_SOURCE"
fi

log "Validating Nginx configuration..."
nginx -t

log "Restarting Nginx..."
systemctl restart nginx

log "Checking Nginx service..."
systemctl is-active --quiet nginx || error "Nginx is not running."

log "Testing local HTTP endpoint..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1)

if [[ "$HTTP_STATUS" != "200" ]]; then
    error "HTTP health check failed. Status: $HTTP_STATUS"
fi

echo
echo "=========================================="
echo " NGINX DEPLOYMENT SUCCESSFUL"
echo " HTTP STATUS: $HTTP_STATUS"
echo " WEB ROOT: $WEB_ROOT"
echo "=========================================="
