
#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

BACKUP_DIR="$ROOT_DIR/backups"

MEGA_REMOTE="/motherboard-systems-hq"

echo "MEGA OFFSITE SYNC START"

command -v mega-put >/dev/null 2>&1 || {

  echo "MEGA CLI NOT AVAILABLE (install MEGAcmd + login)"

  exit 1

}

[ -d "$BACKUP_DIR" ] || { echo "NO BACKUP DIR FOUND"; exit 1; }

MAX_SIZE_MB=500

TOTAL_SIZE_MB=$(du -sm "$BACKUP_DIR" | awk '{print $1}')

echo "BACKUP SIZE: ${TOTAL_SIZE_MB}MB"

[ "$TOTAL_SIZE_MB" -le "$MAX_SIZE_MB" ] || {

  echo "ABORT: FREE TIER LIMIT EXCEEDED"

  exit 1

}

echo "UPLOADING TO MEGA OFFSITE..."

find "$BACKUP_DIR" -type f \( -name "*.tar.gz" -o -name "*.bundle" \) | sort | tail -n 10 | while read -r f; do

  echo "UPLOAD: $f"

  mega-put "$f" "$MEGA_REMOTE/"

  sleep 2

done

echo "MEGA OFFSITE SYNC COMPLETE"

