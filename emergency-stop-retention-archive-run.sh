
#!/usr/bin/env bash

set -euo pipefail

REPORT="emergency-stop-retention-archive-run-$(date +%Y%m%d_%H%M%S).md"

SYSTEM_DIR="$HOME/motherboard-backup-system"

ARCHIVE_DIR="$SYSTEM_DIR/_auto_archives"

{

  echo "# Emergency Stop Retention Archive Run"

  echo

  echo "## Before"

  ps aux | grep -E "verify-retention-manager-repaired-scope-run|snapshot-manager-prod|tar -czf.*_auto_archives" | grep -v grep || true

  echo

} > "$REPORT"

pkill -f verify-retention-manager-repaired-scope-run.sh || true

pkill -f snapshot-manager-prod.sh || true

pkill -f "tar -czf /Users/marcela-dev/motherboard-backup-system/_auto_archives" || true

sleep 3

find "$ARCHIVE_DIR" -maxdepth 1 -type f -name "*-archive-20260529_093807.tar.gz" -delete 2>/dev/null || true

find "$ARCHIVE_DIR" -maxdepth 1 -type f -name "*-archive-20260529_094339.tar.gz" -delete 2>/dev/null || true

{

  echo "## After"

  ps aux | grep -E "verify-retention-manager-repaired-scope-run|snapshot-manager-prod|tar -czf.*_auto_archives" | grep -v grep || true

  echo

  echo "## Archive Dir"

  du -sh "$ARCHIVE_DIR" 2>/dev/null || true

  ls -ltrh "$ARCHIVE_DIR" 2>/dev/null | tail -20 || true

  echo

  echo "## Disk"

  df -h .

  df -h "/Volumes/Rio Drive" 2>/dev/null || true

} >> "$REPORT"

cat "$REPORT"

git add "$REPORT" emergency-stop-retention-archive-run.sh

git commit -m "Emergency stop retention archive run"

git push

