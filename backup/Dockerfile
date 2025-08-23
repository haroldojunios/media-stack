FROM alpine:latest

# Install needed tools
RUN apk add --no-cache \
    bash \
    tzdata \
    lrzip \
    rclone \
    coreutils \
    shadow \
    curl \
    nano \
    cronie

COPY backup-cron /root/

RUN crontab /root/backup-cron

CMD ["crond", "-f", "-m", "off"]
