#!/bin/bash
set -e

XRAY_PORT=${PORT:-8080}
# تنظیم پورت اصلی Xray
sed -i "s/\"port\": 8080/\"port\": $XRAY_PORT/" /usr/local/etc/xray/config.json

# --- ساخت لینک ساب به صورت داینامیک ---
# Railway معمولاً دامنه را در این متغیرها قرار می‌دهد
DOMAIN=${RAILWAY_PUBLIC_DOMAIN:-${RAILWAY_STATIC_URL:-"docker-ubuntu-free-production-5642.up.railway.app"}}
UUID="71bf5c66-95cb-4eb2-9902-b9461b4d6179"

# 1. ساخت لینک VLESS
VLESS="vless://${UUID}@${DOMAIN}:443?encryption=none&security=tls&type=ws&host=${DOMAIN}&path=%2Fvless&sni=${DOMAIN}&fp=chrome#Railway-VLESS"

# 2. ساخت لینک VMess (با Base64 کردن JSON)
VMESS_JSON="{\"v\":\"2\",\"ps\":\"Railway-VMess\",\"add\":\"${DOMAIN}\",\"port\":\"443\",\"id\":\"${UUID}\",\"aid\":\"0\",\"scy\":\"auto\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"${DOMAIN}\",\"path\":\"/vmess\",\"tls\":\"tls\",\"sni\":\"${DOMAIN}\"}"
VMESS_B64=$(echo -n "$VMESS_JSON" | base64 -w 0)
VMESS="vmess://${VMESS_B64}"

# 3. ساخت لینک Shadowsocks
SS_INFO=$(echo -n "chacha20-ietf-poly1305:railway-ss-password-2024" | base64 -w 0)
SS="ss://${SS_INFO}@${DOMAIN}:443?encryption=none&security=tls&type=ws&host=${DOMAIN}&path=%2Fss&sni=${DOMAIN}#Railway-SS"

# 4. ساخت لینک Trojan
TROJAN="trojan://${UUID}@${DOMAIN}:443?security=tls&type=ws&host=${DOMAIN}&path=%2Ftrojan&sni=${DOMAIN}&fp=chrome#Railway-Trojan"

# ترکیب همه لینک‌ها و Base64 کردن کل ساب
SUB_CONTENT="${VLESS}
${VMESS}
${SS}
${TROJAN}"
SUB_B64=$(echo -n "$SUB_CONTENT" | base64 -w 0)

CONTENT_LENGTH=${#SUB_B64}

# ساخت پاسخ HTTP
cat << EOF > /tmp/sub_response.txt
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
Content-Length: $CONTENT_LENGTH
Connection: close

$SUB_B64
EOF

# اجرای سرور ساب روی پورت 80 در بک‌گراند
socat TCP-LISTEN:80,fork,reuseaddr SYSTEM:"cat /tmp/sub_response.txt" &
echo "Sub server started on port 80."

# اجرای نهایی Xray
exec xray run -c /usr/local/etc/xray/config.json