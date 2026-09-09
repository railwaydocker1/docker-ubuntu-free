#!/bin/bash
set -e

# --- Xray: bind to Railway's injected $PORT (fallback 8080) ---
PORT="${PORT:-8080}"
sed -i "s/\"port\": 8080/\"port\": ${PORT}/" /etc/xray/config.json

# --- D-Bus (XFCE needs it) ---
mkdir -p /run/dbus
dbus-daemon --system --fork || true

# --- VNC desktop as vncuser ---
su - vncuser -c "vncserver :1 -localhost yes -rfbport 5901 -geometry 1280x800 -depth 24"

# --- noVNC web UI on 6080 ---
websockify --web /usr/share/novnc 6080 localhost:5901 &

# --- Xray in foreground (keeps container alive) ---
exec xray run -c /etc/xray/config.json
