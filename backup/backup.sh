#!/bin/bash
set -e

NOW=$(date +%Y%m%dT%H%M%S)
DEST="/backups/media-stack-$NOW.tar.lrz"

echo "[INFO] Starting backup at $(date)"

# Compress entire docker folder but exclude the local backup storage
cd /data
tar -cf - . --exclude='./backups' --exclude='./jellyfin/data/metadata' --exclude='./jellyfin/data/data/attachments' --exclude='./jellyfin/cache' | lrzip -o "$DEST"

echo "[INFO] Backup created: $DEST"

# Upload to Google Drive
rclone copy "$DEST" drive:/media-stack-backups

# Local cleanup (older than 7 days)
find /backups -type f -mtime +7 -delete

# Remote cleanup (older than 7 days)
rclone delete drive:/media-stack-backups --min-age 7d

echo "[INFO] Backup finished at $(date)"
