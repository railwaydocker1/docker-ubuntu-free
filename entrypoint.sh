#!/bin/bash
set -e

PORT=${PORT:-8080}
sed -i "s/listen 8080/listen $PORT/" /etc/nginx/nginx.conf

# تنظیمات دامنه عمومی Railway
DOMAIN="http://altaria.proxy.rlwy.net:45182"
PUBLIC_PORT="443"
UUID="71bf5c66-95cb-4eb2-9902-b9461b4d6179"

# ساخت لینک VLESS
VLESS="vless://${UUID}@${DOMAIN}:${PUBLIC_PORT}?encryption=none&security=tls&type=ws&host=${DOMAIN}&path=%2Fvless&sni=${DOMAIN}&fp=chrome#Railway-VLESS"

# ساخت لینک VMess
VMESS_JSON="{\"v\":\"2\",\"ps\":\"Railway-VMess\",\"add\":\"${DOMAIN}\",\"port\":\"${PUBLIC_PORT}\",\"id\":\"${UUID}\",\"aid\":\"0\",\"scy\":\"auto\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"${DOMAIN}\",\"path\":\"/vmess\",\"tls\":\"tls\",\"sni\":\"${DOMAIN}\"}"
VMESS_B64=$(echo -n "$VMESS_JSON" | base64 -w 0)
VMESS="vmess://${VMESS_B64}"

# ساخت لینک Shadowsocks
SS_INFO=$(echo -n "chacha20-ietf-poly1305:railway-ss-password-2024" | base64 -w 0)
SS="ss://${SS_INFO}@${DOMAIN}:${PUBLIC_PORT}?encryption=none&security=tls&type=ws&host=${DOMAIN}&path=%2Fss&sni=${DOMAIN}#Railway-SS"

# ساخت لینک Trojan
TROJAN="trojan://${UUID}@${DOMAIN}:${PUBLIC_PORT}?security=tls&type=ws&host=${DOMAIN}&path=%2Ftrojan&sni=${DOMAIN}&fp=chrome#Railway-Trojan"

mkdir -p /var/www/html
echo -e "${VLESS}\n${VMESS}\n${SS}\n${TROJAN}" > /var/www/html/sub

# استارت Nginx در بک‌گراند
nginx

# اجرای نهایی Xray در فارگراند
exec xray run -c /usr/local/etc/xray/config.json