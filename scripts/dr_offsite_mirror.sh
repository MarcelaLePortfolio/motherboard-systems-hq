
#!/usr/bin/env bash

set -euo pipefail

echo "RUNNING OFFSITE MIRROR LAYER..."

OFFSITE="$HOME/DR_OFFSITE_BACKUP"

mkdir -p "$OFFSITE"

if [ ! -d "./backups" ]; then

  echo "CRITICAL: NO LOCAL BACKUPS FOUND"

  exit 1

fi

echo "COPYING BACKUPS TO OFFSITE LOCATION..."

rsync -av --delete ./backups/ "$OFFSITE/"

echo "OFFSITE MIRROR COMPLETE"

