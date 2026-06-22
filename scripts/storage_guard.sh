
#!/usr/bin/env bash

set -euo pipefail

EXTERNAL="/Volumes/Rio Drive"

BACKUP_ROOT="$EXTERNAL/backups"

# Minimum safe free space (GB)

MIN_FREE_GB=20

FREE_GB=$(df -g "$EXTERNAL" | awk 'NR==2 {print $4}')

echo "FREE SPACE: ${FREE_GB}GB"

if [ "$FREE_GB" -lt "$MIN_FREE_GB" ]; then

  echo "⚠️ LOW SPACE: running emergency cleanup"

  # delete oldest backups until safe

  cd "$BACKUP_ROOT"

  while [ "$(df -g "$EXTERNAL" | awk 'NR==2 {print $4}')" -lt "$MIN_FREE_GB" ]; do

    OLDEST=$(ls -1t source_*.tar.gz 2>/dev/null | tail -n 1 || true)

    if [ -z "$OLDEST" ]; then

      break

    fi

    echo "DELETING: $OLDEST"

    rm -f "$OLDEST"

  done

fi

echo "STORAGE CHECK COMPLETE"

