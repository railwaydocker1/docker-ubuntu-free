#!/bin/bash
set -e

# پورت Xray روی همون پورتی که Railway می‌ده (default 8080)
XRAY_PORT=${PORT:-8080}
sed -i "s/\"port\": 8080/\"port\": $XRAY_PORT/g" /usr/local/etc/xray/config.json

# بالا آوردن VNC
vncserver -localhost no -geometry 1280x800 -rfbauth /root/.vnc/passwd :1

# گواهی TLS برای noVNC
cd /root
openssl req -new -subj "/C=JP" -x509 -days 365 -nodes -out self.pem -keyout self.pem

# noVNC
websockify -D --web=/usr/share/novnc/ --cert=/root/self.pem 6080 localhost:5901

# Xray به صورت foreground — پروسه اصلی کانتینر
exec xray run -c /usr/local/etc/xray/config.json
