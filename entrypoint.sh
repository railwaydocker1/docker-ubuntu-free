#!/bin/bash
set -e

# --- VNC server on display :1 (port 5901) ---
su - vncuser -c "vncserver :1 -geometry 1280x800 -depth 24 -localhost no" || true
export DISPLAY=:1

# --- noVNC via websockify: plain HTTP/WS, daemonized, NO --cert ---
websockify -D --web=/usr/share/novnc 6080

# --- Xray: foreground so the container stays alive ---
exec xray run -c /etc/xray/config.json
