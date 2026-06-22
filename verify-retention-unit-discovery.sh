
#!/usr/bin/env bash

set -euo pipefail

REPORT="retention-unit-discovery-$(date +%Y%m%d_%H%M%S).md"

is_backup_file() {

  case "$1" in

    *.tar.gz|*.bundle) return 0 ;;

    *) return 1 ;;

  esac

}

scan_root() {

  root="$1"

  echo "## $root"

  echo

  if [ ! -d "$root" ]; then

    echo "exists: NO"

    echo

    return

  fi

  echo "exists: YES"

  du -sh "$root" 2>/dev/null || true

  echo

  echo "### Top-level files"

  find "$root" -maxdepth 1 -type f -print 2>/dev/null | sort | while IFS= read -r f; do

    if is_backup_file "$f"; then

      echo "$f"

    fi

  done | sed -n '1,120p'

  echo

  echo "### Top-level directories containing backup files"

  find "$root" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null | sort | while IFS= read -r dir; do

    nested_count="$(find "$dir" -type f -print 2>/dev/null | while IFS= read -r f; do is_backup_file "$f" && echo "$f"; done | wc -l | tr -d ' ')"

    if [ "$nested_count" != "0" ]; then

      size="$(du -sh "$dir" 2>/dev/null | awk '{print $1}')"

      echo "$size | nested_backup_files=$nested_count | $dir"

    fi

  done

  echo

  echo "### Counts"

  top_level_files="$(find "$root" -maxdepth 1 -type f -print 2>/dev/null | while IFS= read -r f; do is_backup_file "$f" && echo "$f"; done | wc -l | tr -d ' ')"

  top_level_dirs_with_backup_files="$(find "$root" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null | while IFS= read -r dir; do find "$dir" -type f -print 2>/dev/null | while IFS= read -r f; do is_backup_file "$f" && echo "$dir" && break; done; done | wc -l | tr -d ' ')"

  echo "top_level_files=$top_level_files"

  echo "top_level_dirs_with_backup_files=$top_level_dirs_with_backup_files"

  echo

}

{

  echo "# Retention Unit Discovery Verification"

  echo

  echo "This is read-only. It identifies backup units without deleting, archiving, or compressing anything."

  echo

  scan_root "/Volumes/Rio Drive/backups"

  scan_root "/Volumes/Rio Drive/Motherboard_External_Backup/snapshots"

  scan_root "$HOME/Projects/motherboard-systems-hq-clean/backups"

  echo "## Current Manager Metrics"

  cat "$HOME/motherboard-backup-system/last-run-metrics.json" 2>/dev/null || true

  echo

  echo "## Current Manager Reconciliation"

  cat "$HOME/motherboard-backup-system/reconciliation.json" 2>/dev/null || true

} > "$REPORT"

cat "$REPORT"

git add "$REPORT" verify-retention-unit-discovery.sh

git commit -m "Verify retention unit discovery"

git push

