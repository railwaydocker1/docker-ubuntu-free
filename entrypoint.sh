#!/bin/bash
set -e

XRAY_PORT=${PORT:-8080}
# فقط اولین پورت (VLESS) را تغییر می‌دهیم تا پورت‌های داخلی Fallback دست‌نخورده باقی بمانند
sed -i "s/\"port\": 8080/\"port\": $XRAY_PORT/" /usr/local/etc/xray/config.json

exec xray run -c /usr/local/etc/xray/config.json