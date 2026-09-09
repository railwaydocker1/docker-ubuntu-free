#!/bin/bash
set -e

# پورت Xray روی همون پورتی که Railway می‌ده (default 8080)
XRAY_PORT=${PORT:-8080}

# جایگزین کردن پورت در config.json (با یک Regex مطمئن که در ری‌استارت‌های کانتینر هم درست کار کند)
sed -i -E "s/\"port\":[[:space:]]*[0-9]+/\"port\": $XRAY_PORT/g" /usr/local/etc/xray/config.json

# اجرای Xray به صورت foreground (پروسه اصلی کانتینر که نباید متوقف شود)
exec xray run -c /usr/local/etc/xray/config.json
