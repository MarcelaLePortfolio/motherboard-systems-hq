
#!/usr/bin/env bash

set -e

BACKUP_ROOT="./backups"

EXTERNAL_ROOT="/Volumes/EXTERNAL_BACKUP_DRIVE/motherboard-systems-hq"

echo "SYNCING TO EXTERNAL DRIVE..."

if [ ! -d "$EXTERNAL_ROOT" ]; then

  echo "ERROR: External drive not mounted"

  exit 1

fi

rsync -av --delete "$BACKUP_ROOT/" "$EXTERNAL_ROOT/"

echo "EXTERNAL SYNC COMPLETE"

