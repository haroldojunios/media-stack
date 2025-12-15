#!/bin/bash
set -e

NOW=$(date +%Y%m%dT%H%M%S)
DEST="/backups/media-stack-$NOW.tar.zst"

echo "[INFO] Starting backup at $(date)"

# Compress entire docker folder but exclude the local backup storage
cd /data
tar -cf - --exclude='backups' --exclude='jellyfin/data/metadata' --exclude='jellyfin/data/data/attachments' --exclude='jellyfin/cache' -- * | zstd -9 -T0 --long --no-progress -o "$DEST"
echo "[INFO] Backup created: $DEST"

# Upload to Google Drive
rclone copy "$DEST" drive:/media-stack-backups
echo "[INFO] Backup uploaded to Google Drive"

# Local cleanup (older than 7 days)
find /backups -type f -name '*.tar.zst' -mtime +7 -delete
echo "[INFO] Local backups cleaned up"

# Remote cleanup (older than 3 days)
rclone --verbose --min-age 3d --drive-use-trash=false delete drive:/media-stack-backups
echo "[INFO] Remote backups cleaned up"

echo "[INFO] Backup finished at $(date)"
