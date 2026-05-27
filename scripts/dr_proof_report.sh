
#!/usr/bin/env bash

set -euo pipefail

echo "GENERATING DR SYSTEM PROOF REPORT..."

ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

echo ""

echo "=== BACKUP STATE ==="

ls -lah "$ROOT/backups" | tail -n 20 || true

echo ""

echo "=== DISK USAGE ==="

df -h .

echo ""

echo "=== EXTERNAL DRIVE ==="

if [ -d "/Volumes/EXTERNAL_BACKUP_DRIVE" ]; then

  echo "EXTERNAL: MOUNTED"

  df -h /Volumes/EXTERNAL_BACKUP_DRIVE || true

else

  echo "EXTERNAL: NOT MOUNTED"

fi

echo ""

echo "=== RECENT BACKUPS (COUNT CHECK) ==="

ls "$ROOT/backups" | grep -E "repo_|source_" | wc -l || true

echo ""

echo "=== DR LOG STATUS ==="

[ -f logs/dr.log ] && tail -n 10 logs/dr.log || echo "NO LOG FILE"

echo ""

echo "DR PROOF REPORT COMPLETE"

