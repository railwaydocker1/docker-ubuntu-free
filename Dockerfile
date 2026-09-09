FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-terminal \
    tigervnc-standalone-server \
    tigervnc-common \
    novnc \
    websockify \
    firefox \
    dbus-x11 \
    x11-utils \
    net-tools \
    curl \
    ca-certificates \
    unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# --- Xray ---
ARG XRAY_VERSION=v1.8.24
RUN curl -fsSL -o /tmp/xray.zip \
    "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip" \
    && unzip -o /tmp/xray.zip -d /usr/local/bin xray \
    && chmod +x /usr/local/bin/xray \
    && mkdir -p /etc/xray /var/log/xray \
    && rm /tmp/xray.zip

# --- VNC user (fixed: uses vncpasswd from tigervnc-common, NOT x11vnc) ---
RUN useradd -m -s /bin/bash vncuser \
    && mkdir -p /home/vncuser/.vnc \
    && printf 'vncuser\n' | vncpasswd -f > /home/vncuser/.vnc/passwd \
    && chmod 600 /home/vncuser/.vnc/passwd \
    && printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec startxfce4\n' > /home/vncuser/.vnc/xstartup \
    && chmod +x /home/vncuser/.vnc/xstartup \
    && chown -R vncuser:vncuser /home/vncuser

COPY config.json /etc/xray/config.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 8080 = Xray (VLESS+WS)  |  6080 = noVNC  |  5901 = raw VNC
EXPOSE 8080 6080 5901

ENTRYPOINT ["/entrypoint.sh"]
