#!/bin/bash
set -e

# پورت Xray رو با PORT ریلیوی ست کن
XRAY_PORT=${PORT:-8080}
sed -i "s/\"port\": 8080/\"port\": $XRAY_PORT/" /usr/local/etc/xray/config.json

# VNC به‌عنوان vncuser (با پسورد)
su - vncuser -c "vncserver :1 -geometry 1280x800 -SecurityTypes VncAuth -PasswordFile /home/vncuser/.vnc/passwd -localhost no"

# noVNC روی 6080 (بدون cert — TLS رو خود Railway هندل می‌کنه)
websockify -D --web=/usr/share/novnc/ 6080 localhost:5901

# Xray به‌عنوان پروسه اصلی
exec xray run -c /usr/local/etc/xray/config.json
