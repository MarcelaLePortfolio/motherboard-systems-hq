
#!/usr/bin/env bash

set -euo pipefail

REPORT="retention-manager-count-snapshot-dirs-repair-$(date +%Y%m%d_%H%M%S).md"

SYSTEM_DIR="$HOME/motherboard-backup-system"

MANAGER="$SYSTEM_DIR/snapshot-manager-prod.sh"

BACKUP_COPY="$SYSTEM_DIR/snapshot-manager-prod.sh.pre-count-snapshot-dirs-$(date +%Y%m%d_%H%M%S)"

DOMAIN="gui/$(id -u)"

LABEL="com.motherboard.snapshot.retention"

cp "$MANAGER" "$BACKUP_COPY"

python3 - << 'PY'

from pathlib import Path

manager = Path.home() / "motherboard-backup-system" / "snapshot-manager-prod.sh"

text = manager.read_text()

old = '''elif [ -d "$p" ] && dir_has_backup_file "$p"; then

      mt="$(stat -f %m "$p" 2>/dev/null || echo 0)"

      sz="$(du -sk "$p" 2>/dev/null | awk '{print $1 * 1024}')"

      echo "$mt $sz DIR $p" >> "$UNIT_LIST"

    fi'''

new = '''elif [ -d "$p" ]; then

      mt="$(stat -f %m "$p" 2>/dev/null || echo 0)"

      sz="$(du -sk "$p" 2>/dev/null | awk '{print $1 * 1024}')"

      echo "$mt $sz DIR $p" >> "$UNIT_LIST"

    fi'''

if old not in text:

    raise SystemExit("Expected directory discovery block not found; refusing blind patch.")

manager.write_text(text.replace(old, new))

PY

: > "$SYSTEM_DIR/launchd.out.log"

: > "$SYSTEM_DIR/launchd.err.log"

bash -n "$MANAGER"

launchctl kickstart -k "$DOMAIN/$LABEL" || true

sleep 5

{

  echo "# Retention Manager Count Snapshot Dirs Repair"

  echo

  echo "Backup copy: $BACKUP_COPY"

  echo

  echo "## Fresh stderr"

  cat "$SYSTEM_DIR/launchd.err.log" 2>/dev/null || true

  echo

  echo "## Metrics"

  cat "$SYSTEM_DIR/last-run-metrics.json" 2>/dev/null || true

  echo

  echo "## Reconciliation"

  cat "$SYSTEM_DIR/reconciliation.json" 2>/dev/null || true

  echo

  echo "## One-line Reality Check"

  echo -n "external_units="

  find "/Volumes/Rio Drive/Motherboard_External_Backup/snapshots" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' '

  echo -n " local_units="

  find "/Users/marcela-dev/Projects/motherboard-systems-hq-clean/backups" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' '

  echo -n " scanned="

  grep '"scanned"' "$SYSTEM_DIR/last-run-metrics.json" | grep -o '[0-9]\+' | head -1

} > "$REPORT"

cat "$REPORT"

git add "$REPORT" repair-retention-manager-count-snapshot-dirs.sh

git commit -m "Repair retention manager snapshot directory counting"

git push

