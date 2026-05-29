
#!/usr/bin/env bash

set -euo pipefail

REPORT="retention-direct-vs-launchagent-$(date +%Y%m%d_%H%M%S).md"

SYSTEM_DIR="$HOME/motherboard-backup-system"

MANAGER="$SYSTEM_DIR/snapshot-manager-prod.sh"

DOMAIN="gui/$(id -u)"

LABEL="com.motherboard.snapshot.retention"

: > "$SYSTEM_DIR/launchd.out.log"

: > "$SYSTEM_DIR/launchd.err.log"

bash -n "$MANAGER"

/bin/bash "$MANAGER"

DIRECT_METRICS="$(cat "$SYSTEM_DIR/last-run-metrics.json" 2>/dev/null || true)"

DIRECT_RECON="$(cat "$SYSTEM_DIR/reconciliation.json" 2>/dev/null || true)"

launchctl kickstart -k "$DOMAIN/$LABEL" || true

sleep 5

LAUNCHD_METRICS="$(cat "$SYSTEM_DIR/last-run-metrics.json" 2>/dev/null || true)"

LAUNCHD_RECON="$(cat "$SYSTEM_DIR/reconciliation.json" 2>/dev/null || true)"

{

  echo "# Retention Direct vs LaunchAgent Comparison"

  echo

  echo "## One-line Inventory"

  printf "external_dirs="

  find "/Volumes/Rio Drive/Motherboard_External_Backup/snapshots" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' '

  printf " rio_backups_dirs="

  find "/Volumes/Rio Drive/backups" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' '

  printf " local_dirs="

  find "$HOME/Projects/motherboard-systems-hq-clean/backups" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' '

  echo

  echo

  echo "## Direct Shell Metrics"

  echo "$DIRECT_METRICS"

  echo

  echo "## Direct Shell Reconciliation"

  echo "$DIRECT_RECON"

  echo

  echo "## LaunchAgent Metrics"

  echo "$LAUNCHD_METRICS"

  echo

  echo "## LaunchAgent Reconciliation"

  echo "$LAUNCHD_RECON"

  echo

  echo "## LaunchAgent stderr"

  cat "$SYSTEM_DIR/launchd.err.log" 2>/dev/null || true

  echo

  echo "## Current Unit File Counts"

  for f in "$SYSTEM_DIR"/.retention-units-*.txt; do

    [ -f "$f" ] || continue

    echo "$(basename "$f") count=$(wc -l < "$f" | tr -d ' ')"

  done

} > "$REPORT"

cat "$REPORT"

git add "$REPORT" compare-retention-direct-vs-launchagent.sh

git commit -m "Compare retention direct and launchagent execution"

git push

