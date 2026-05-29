
#!/usr/bin/env bash

set -euo pipefail

REPORT="retention-file-discovery-$(date +%Y%m%d_%H%M%S).md"

ROOT_LIST="$(mktemp)"

cat > "$ROOT_LIST" << ROOTS

/Volumes/Rio Drive/backups

/Volumes/Rio Drive/Motherboard_External_Backup/snapshots

$HOME/Projects/motherboard-systems-hq-clean/backups

ROOTS

{

  echo "# Retention File Discovery Verification"

  echo

  echo "## Managed Root Inventory"

  echo

  while IFS= read -r root; do

    echo "### $root"

    if [ -d "$root" ]; then

      echo "exists: YES"

      du -sh "$root" 2>/dev/null || true

      echo

      echo "top-level backup files:"

      find "$root" -maxdepth 1 -type f \( -name "*.tar.gz" -o -name "*.bundle" \) -print 2>/dev/null | sort | head -80

      echo

      echo "top-level backup file count:"

      find "$root" -maxdepth 1 -type f \( -name "*.tar.gz" -o -name "*.bundle" \) -print 2>/dev/null | wc -l

      echo

      echo "nested backup file count:"

      find "$root" -type f \( -name "*.tar.gz" -o -name "*.bundle" \) -print 2>/dev/null | wc -l

    else

      echo "exists: NO"

    fi

    echo

  done < "$ROOT_LIST"

  echo "## Manager Current Metrics"

  echo

  cat "$HOME/motherboard-backup-system/last-run-metrics.json" 2>/dev/null || true

  echo

  echo "## Manager Current Reconciliation"

  echo

  cat "$HOME/motherboard-backup-system/reconciliation.json" 2>/dev/null || true

} > "$REPORT"

rm -f "$ROOT_LIST"

cat "$REPORT"

git add "$REPORT" verify-retention-file-discovery.sh

git commit -m "Verify retention file discovery"

git push

