
#!/usr/bin/env bash

set -euo pipefail

EXTERNAL="/Volumes/Rio Drive"

BACKUP_ROOT="$EXTERNAL/backups"

KEEP_LAST=10

cd "$BACKUP_ROOT" || exit 0

echo "RUNNING RETENTION ENGINE"

# ONLY SAFE DELETE LOGIC (STRICT ORDERING)

ls -1t source_*.tar.gz 2>/dev/null | tail -n +$((KEEP_LAST+1)) | while read -r f; do

  echo "DELETE $f"

  rm -f "$f"

done

ls -1t repo_*.bundle 2>/dev/null | tail -n +$((KEEP_LAST+1)) | while read -r f; do

  echo "DELETE $f"

  rm -f "$f"

done

echo "RETENTION COMPLETE"

