
#!/usr/bin/env bash

set -euo pipefail

REPORT="retention-unit-lists-inspection-$(date +%Y%m%d_%H%M%S).md"

SYSTEM_DIR="$HOME/motherboard-backup-system"

{

  echo "# Retention Unit Lists Inspection"

  echo

  echo "## One-line Counts"

  printf "external_units="

  find "/Volumes/Rio Drive/Motherboard_External_Backup/snapshots" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' '

  printf " local_units="

  find "$HOME/Projects/motherboard-systems-hq-clean/backups" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' '

  printf " rio_backups_units="

  find "/Volumes/Rio Drive/backups" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' '

  printf " scanned="

  grep '"scanned"' "$SYSTEM_DIR/last-run-metrics.json" | grep -o '[0-9]\+' | head -1

  echo

  echo

  echo "## Generated Retention Unit Files"

  ls -ltrh "$SYSTEM_DIR"/.retention-units-*.txt 2>/dev/null || true

  echo

  echo "## Unit File Counts"

  for f in "$SYSTEM_DIR"/.retention-units-*.txt; do

    [ -f "$f" ] || continue

    echo "$(basename "$f") count=$(wc -l < "$f" | tr -d ' ')"

    sed -n '1,12p' "$f"

    echo

  done

  echo "## Manager Root Configuration"

  grep -nE 'for BASE in|Motherboard_External_Backup|Rio Drive/backups|motherboard-systems-hq-clean/backups|UNIT_LIST|find "\$BASE"' "$SYSTEM_DIR/snapshot-manager-prod.sh" || true

} > "$REPORT"

cat "$REPORT"

git add "$REPORT" inspect-retention-unit-lists.sh

git commit -m "Inspect retention unit lists"

git push

