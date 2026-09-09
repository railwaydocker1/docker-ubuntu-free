FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
# تعیین مسیر فایل‌های دیتابیس Xray (geoip و geosite)
ENV XRAY_LOCATION_ASSET=/usr/local/share/xray

# پکیج‌های پایه (unzip برای استخراج فایل Xray لازم است)
RUN apt update -y && apt install --no-install-recommends -y \
    ca-certificates curl wget unzip \
    net-tools tzdata && \
    rm -rf /var/lib/apt/lists/*

# دانلود مستقیم هسته Xray (بدون نیاز به اسکریپت systemd)
RUN mkdir -p /usr/local/etc/xray /usr/local/share/xray && \
    curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip /tmp/xray.zip -d /tmp/xray && \
    mv /tmp/xray/xray /usr/local/bin/ && \
    mv /tmp/xray/geoip.dat /usr/local/share/xray/ && \
    mv /tmp/xray/geosite.dat /usr/local/share/xray/ && \
    chmod +x /usr/local/bin/xray && \
    rm -rf /tmp/xray /tmp/xray.zip

# کپی فایل‌ها
COPY config.json /usr/local/etc/xray/config.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080

CMD ["/entrypoint.sh"]
