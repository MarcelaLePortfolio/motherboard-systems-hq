
#!/usr/bin/env bash

set -euo pipefail

EXTERNAL="/Volumes/EXTERNAL_BACKUP_DRIVE"

echo "CHECKING EXTERNAL BACKUP LAYER..."

if [ ! -d "$EXTERNAL" ]; then

  echo "PRIMARY EXTERNAL DRIVE NOT FOUND"

  echo "STATE: OFFLINE MIRROR DEGRADED"

  exit 1

fi

DISK_SPACE=$(df -h "$EXTERNAL" | awk 'NR==2 {print $5}')

echo "EXTERNAL DRIVE STATUS OK"

echo "USAGE: $DISK_SPACE"

