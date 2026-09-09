FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# پکیج‌های پایه + gnupg (لازم برای PPA) + tigervnc-common (لازم برای vncpasswd)
RUN apt update -y && apt install --no-install-recommends -y \
    gnupg gpg-agent software-properties-common \
    ca-certificates curl wget git unzip openssl \
    tigervnc-standalone-server tigervnc-common \
    novnc websockify \
    sudo xterm vim net-tools tzdata \
    dbus-x11 x11-utils x11-xserver-utils x11-apps \
    init systemd snapd

# دسکتاپ XFCE
RUN apt update -y && apt install --no-install-recommends -y xfce4 xfce4-goodies

# Firefox از PPA (gnupg از مرحله قبل موجوده، پس gpg-agent error نمی‌ده)
RUN add-apt-repository ppa:mozillateam/ppa -y && \
    echo 'Package: *' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:jammy";' | tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox && \
    apt update -y && apt install -y firefox xubuntu-icon-theme

# نصب Xray
RUN bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# ساخت پسورد VNC (بعد از نصب tigervnc-common، پس دیگه not found نمی‌ده)
RUN mkdir -p /root/.vnc && \
    echo "vncpass123" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# فایل xstartup برای XFCE
RUN printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec startxfce4\n' > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# کپی فایل‌ها
COPY config.json /usr/local/etc/xray/config.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN touch /root/.Xauthority

EXPOSE 5901
EXPOSE 6080
EXPOSE 8080

CMD ["/entrypoint.sh"]
