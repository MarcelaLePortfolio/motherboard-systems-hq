
#!/usr/bin/env bash

set -euo pipefail

BACKUP_ROOT="./backups"

EXTERNAL_ROOT="/Volumes/EXTERNAL_BACKUP_DRIVE/motherboard-systems-hq"

echo "SYNCING TO EXTERNAL DRIVE..."

# HARD GUARD: never attempt rsync if mount is invalid

if [ ! -d "$EXTERNAL_ROOT" ] || ! mount | grep -q "EXTERNAL_BACKUP_DRIVE"; then

  echo "WARNING: External drive not mounted. Skipping sync safely."

  exit 0

fi

mkdir -p "$EXTERNAL_ROOT"

rsync -av --delete "$BACKUP_ROOT/" "$EXTERNAL_ROOT/"

echo "EXTERNAL SYNC COMPLETE"

