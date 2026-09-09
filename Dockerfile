FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# پکیج‌های اصلی — اول اینا نصب میشن
RUN apt update -y && apt install --no-install-recommends -y \
    xfce4 xfce4-goodies \
    tigervnc-standalone-server tigervnc-common \
    novnc websockify \
    sudo xterm init systemd snapd vim net-tools curl wget git tzdata \
    dbus-x11 x11-utils x11-xserver-utils x11-apps \
    software-properties-common ca-certificates unzip openssl

# Firefox از PPA
RUN apt update -y && apt install -y gnupg gpg-agent software-properties-common

# ساخت کاربر VNC — حتماً بعد از نصب tigervnc (چون vncpasswd لازمه)
RUN useradd -m -s /bin/bash vncuser && \
    mkdir -p /home/vncuser/.vnc && \
    printf 'vncuser\n' | vncpasswd -f > /home/vncuser/.vnc/passwd && \
    chmod 600 /home/vncuser/.vnc/passwd && \
    printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec startxfce4\n' > /home/vncuser/.vnc/xstartup && \
    chmod +x /home/vncuser/.vnc/xstartup && \
    touch /home/vncuser/.Xauthority && \
    chown -R vncuser:vncuser /home/vncuser

# نصب Xray
RUN bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

COPY config.json /usr/local/etc/xray/config.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 5901
EXPOSE 6080
EXPOSE 8080

CMD ["/entrypoint.sh"]
