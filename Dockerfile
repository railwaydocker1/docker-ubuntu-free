FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# پکیج‌های پایه (حذف دسکتاپ، VNC و Firefox برای سبک شدن شدید ایمیج)
RUN apt update -y && apt install --no-install-recommends -y \
    ca-certificates curl wget git unzip openssl \
    sudo net-tools tzdata

# نصب Xray
RUN bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# کپی فایل‌ها
COPY config.json /usr/local/etc/xray/config.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080

CMD ["/entrypoint.sh"]
