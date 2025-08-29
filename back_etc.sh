#!/bin/bash
set -euo pipefail

DEST="/var/backups/etc"
mkdir -p "$DEST"

ARCHIVE="$DEST/etc-$(date +%F).tar.gz"
tar -czf "$ARCHIVE" /etc

# 刪除 7 天前的舊備份
find "$DEST" -type f -name 'etc-*.tar.gz' -mtime +7 -delete

echo "Backup done: $ARCHIVE"
