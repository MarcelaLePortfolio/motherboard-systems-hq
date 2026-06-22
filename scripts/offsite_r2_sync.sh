
#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

BACKUP_DIR="$ROOT_DIR/backups"

R2_REMOTE="r2:motherboard-systems-hq"

echo "OFFSITE R2 SYNC START (RCLONE MODE)"

command -v rclone >/dev/null 2>&1 || {

  echo "RCLONE NOT INSTALLED"

  exit 1

}

[ -d "$BACKUP_DIR" ] || { echo "NO BACKUPS FOUND"; exit 1; }

LATEST=$(ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | head -n 1 || true)

if [ -z "$LATEST" ]; then

  echo "NO ARCHIVE FOUND"

  exit 0

fi

echo "UPLOADING: $LATEST"

rclone copy "$LATEST" "$R2_REMOTE" --progress

echo "OFFSITE SYNC COMPLETE"

