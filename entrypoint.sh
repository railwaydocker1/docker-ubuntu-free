#!/bin/bash
set -e

XRAY_PORT=${PORT:-8080}
# تنظیم پورت اصلی Xray
sed -i "s/\"port\": 8080/\"port\": $XRAY_PORT/" /usr/local/etc/xray/config.json

# --- ساخت لینک ساب به صورت داینامیک ---
# Railway دامنه عمومی را در متغیر RAILWAY_STATIC_URL قرار می‌دهد
DOMAIN=${RAILWAY_STATIC_URL:-"docker-ubuntu-free-production-5642.up.railway.app"}
UUID="71bf5c66-95cb-4eb2-9902-b9461b4d6179"

# استفاده از Python برای ساخت دقیق فرمت‌های JSON و Base64 (چون در اوبونتو نصب است)
python3 -c "
import json, base64
domain = '$DOMAIN'
uuid = '$UUID'

vless = f'vless://{uuid}@{domain}:443?encryption=none&security=tls&type=ws&host={domain}&path=%2Fvless&sni={domain}&fp=chrome#Railway-VLESS'

vmess_c = {'v':'2','ps':'Railway-VMess','add':domain,'port':'443','id':uuid,'aid':'0','scy':'auto','net':'ws','type':'none','host':domain,'path':'/vmess','tls':'tls','sni':domain}
vmess = 'vmess://' + base64.b64encode(json.dumps(vmess_c, separators=(',', ':')).encode()).decode()

ss_c = base64.b64encode('chacha20-ietf-poly1305:railway-ss-password-2024'.encode()).decode()
ss = f'ss://{ss_c}@{domain}:443?encryption=none&security=tls&type=ws&host={domain}&path=%2Fss&sni={domain}#Railway-SS'

trojan = f'trojan://{uuid}@{domain}:443?security=tls&type=ws&host={domain}&path=%2Ftrojan&sni={domain}&fp=chrome#Railway-Trojan'

sub = f'{vless}\n{vmess}\n{ss}\n{trojan}'
print(base64.b64encode(sub.encode()).decode())
" > /tmp/sub_b64.txt

SUB_B64=$(cat /tmp/sub_b64.txt)
CONTENT_LENGTH=${#SUB_B64}

# ساخت هدر و محتوای پاسخ HTTP
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