#!/bin/bash
set -e

# ست کردن پورت Xray روی PORT ای که Railway میده (default 8080)
XRAY_PORT=${PORT:-8080}
sed -i "s/\"port\": 8080/\"port\": $XRAY_PORT/g" /usr/local/etc/xray/config.json

# بالا آوردن VNC
vncserver -localhost no -SecurityTypes None -geometry 1280x800 --I-KNOW-THIS-IS-INSECURE :1

# ساخت گواهی TLS برای noVNC
cd /root
openssl req -new -subj "/C=JP" -x509 -days 365 -nodes -out self.pem -keyout self.pem

# بالا آوردن noVNC
websockify -D --web=/usr/share/novnc/ --cert=/root/self.pem 6080 localhost:5901

# اجرای Xray (foreground، پروسه اصلی کانتینر)
exec xray run -c /usr/local/etc/xray/config.json
