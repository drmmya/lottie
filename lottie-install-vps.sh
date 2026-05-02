#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/var/www/html/lottie}"
APP_V3_DIR="${APP_V3_DIR:-/var/www/html/lottie-v3}"
CONF="/etc/apache2/conf-available/lottie-folder-safe.conf"
BACKUP="/etc/apache2/conf-available/lottie-folder-safe.conf.backup.$(date +%Y%m%d_%H%M%S)"

echo "Lottie HTTPS/Apache safe folder config"
echo "This script will NOT install/restart Nginx."
echo "This script will NOT stop Apache, ocserv, OpenVPN, V2Ray, or panel services."
echo "It only adds an Apache Alias for /lottie/ and /lottie-v3/, then reloads Apache if configtest passes."
echo ""

if [ "$(id -u)" -ne 0 ]; then
  echo "Please run as root: sudo bash $0"
  exit 1
fi

if ! command -v apache2ctl >/dev/null 2>&1; then
  echo "apache2ctl not found. This safe script is for Apache only."
  exit 1
fi

if [ ! -f "$APP_DIR/index.html" ]; then
  echo "Missing: $APP_DIR/index.html"
  echo "Install the Lottie app first, then run this script."
  exit 1
fi

mkdir -p "$APP_DIR" "$APP_V3_DIR"

# Keep lottie-v3 same as lottie if v3 folder is missing.
if [ ! -f "$APP_V3_DIR/index.html" ]; then
  cp -a "$APP_DIR/index.html" "$APP_V3_DIR/index.html"
fi

if [ -f "$CONF" ]; then
  cp -a "$CONF" "$BACKUP"
  echo "Backup saved: $BACKUP"
fi

cat > "$CONF" <<EOF
# Safe Lottie static folder alias
# Applies to Apache HTTP and HTTPS vhosts served by this Apache instance.
Alias /lottie/ "$APP_DIR/"
Alias /lottie-v3/ "$APP_V3_DIR/"

<Directory "$APP_DIR/">
    Options -Indexes +FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>

<Directory "$APP_V3_DIR/">
    Options -Indexes +FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>

<IfModule mod_headers.c>
    <Location "/lottie/">
        Header set Cache-Control "no-store, no-cache, must-revalidate, max-age=0"
        Header set Pragma "no-cache"
    </Location>
    <Location "/lottie-v3/">
        Header set Cache-Control "no-store, no-cache, must-revalidate, max-age=0"
        Header set Pragma "no-cache"
    </Location>
</IfModule>
EOF

# Enable harmless headers module for no-cache headers, if available.
a2enmod headers >/dev/null 2>&1 || true
a2enconf lottie-folder-safe >/dev/null

echo "Testing Apache config..."
if apache2ctl configtest; then
  echo "Config OK. Reloading Apache safely..."
  systemctl reload apache2
  echo ""
  echo "Done."
  echo "Test:"
  echo "  curl -I http://127.0.0.1/lottie/"
  echo "  curl -kI https://YOUR_DOMAIN/lottie/"
  echo "  curl -sk https://YOUR_DOMAIN/lottie/?v=v3-53 | grep VERSION-LottieMaker-V3-53"
else
  echo "Config test failed. Disabling lottie-folder-safe to avoid breaking services."
  a2disconf lottie-folder-safe >/dev/null 2>&1 || true
  [ -f "$BACKUP" ] && cp -a "$BACKUP" "$CONF"
  exit 1
fi
