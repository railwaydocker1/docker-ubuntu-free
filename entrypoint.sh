#!/bin/bash
set -e

PORT=${PORT:-8080}
sed -i "s/listen 8080/listen $PORT/" /etc/nginx/nginx.conf

# تنظیمات جدید بر اساس Public TCP Port شما
DOMAIN="docker-ubuntu-free-production-5642.up.railway.app"
PUBLIC_PORT="39814"
UUID="71bf5c66-95cb-4eb2-9902-b9461b4d6179"

# توجه: چون proxy.rlwy.net گواهی SSL ندارد، security را روی none می‌گذاریم
VLESS="vless://${UUID}@${DOMAIN}:${PUBLIC_PORT}?encryption=none&security=none&type=ws&path=%2Fvless#Railway-VLESS"

VMESS_JSON="{\"v\":\"2\",\"ps\":\"Railway-VMess\",\"add\":\"${DOMAIN}\",\"port\":\"${PUBLIC_PORT}\",\"id\":\"${UUID}\",\"aid\":\"0\",\"scy\":\"auto\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"${DOMAIN}\",\"path\":\"/vmess\",\"tls\":\"\"}"
VMESS_B64=$(echo -n "$VMESS_JSON" | base64 -w 0)
VMESS="vmess://${VMESS_B64}"

SS_INFO=$(echo -n "chacha20-ietf-poly1305:railway-ss-password-2024" | base64 -w 0)
SS="ss://${SS_INFO}@${DOMAIN}:${PUBLIC_PORT}?encryption=none&security=none&type=ws&path=%2Fss#Railway-SS"

TROJAN="trojan://${UUID}@${DOMAIN}:${PUBLIC_PORT}?security=none&type=ws&path=%2Ftrojan#Railway-Trojan"

mkdir -p /var/www/html
echo -e "${VLESS}\n${VMESS}\n${SS}\n${TROJAN}" > /var/www/html/sub

# استارت Nginx و Xray
nginx
exec xray run -c /usr/local/etc/xray/config.json