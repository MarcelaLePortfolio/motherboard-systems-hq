
#!/usr/bin/env bash

set -euo pipefail

REPORT="retention-manager-repaired-scope-run-$(date +%Y%m%d_%H%M%S).md"

DOMAIN="gui/$(id -u)"

LABEL="com.motherboard.snapshot.retention"

ROOT="$HOME/motherboard-backup-system"

MANAGER="$ROOT/snapshot-manager-prod.sh"

BEFORE_HEARTBEAT="$(cat "$ROOT/last-heartbeat.txt" 2>/dev/null || true)"

: > "$ROOT/launchd.out.log"

: > "$ROOT/launchd.err.log"

bash -n "$MANAGER"

/bin/bash "$MANAGER"

sleep 2

AFTER_DIRECT_HEARTBEAT="$(cat "$ROOT/last-heartbeat.txt" 2>/dev/null || true)"

launchctl kickstart -k "$DOMAIN/$LABEL" || true

sleep 5

{

  echo "# Retention Manager Repaired Scope Run Verification"

  echo

  echo "Repo: $(git rev-parse --show-toplevel)"

  echo "Branch: $(git branch --show-current)"

  echo "HEAD: $(git rev-parse HEAD)"

  echo

  echo "## Configured Managed Roots"

  grep -n "/Volumes/Rio Drive/backups\|Motherboard_External_Backup\|motherboard-systems-hq-clean/backups" "$MANAGER" || true

  echo

  echo "## Before Heartbeat"

  echo "$BEFORE_HEARTBEAT"

  echo

  echo "## After Direct Run Heartbeat"

  echo "$AFTER_DIRECT_HEARTBEAT"

  echo

  echo "## LaunchAgent Status"

  launchctl print "$DOMAIN/$LABEL" 2>&1 || true

  echo

  echo "## Fresh stderr"

  cat "$ROOT/launchd.err.log" 2>/dev/null || true

  echo

  echo "## Fresh stdout"

  cat "$ROOT/launchd.out.log" 2>/dev/null || true

  echo

  echo "## Current Status"

  cat "$ROOT/last-run-status.txt" 2>/dev/null || true

  echo

  echo "## Current Heartbeat"

  cat "$ROOT/last-heartbeat.txt" 2>/dev/null || true

  echo

  echo "## Current Metrics"

  cat "$ROOT/last-run-metrics.json" 2>/dev/null || true

  echo

  echo "## Current Reconciliation"

  cat "$ROOT/reconciliation.json" 2>/dev/null || true

  echo

  echo "## Managed Locations"

  echo

  du -sh backups 2>/dev/null || true

  du -sh "/Volumes/Rio Drive/backups" 2>/dev/null || true

  du -sh "/Volumes/Rio Drive/Motherboard_External_Backup/snapshots" 2>/dev/null || true

} > "$REPORT"

cat "$REPORT"

git add "$REPORT" verify-retention-manager-repaired-scope-run.sh

git commit -m "Verify repaired retention manager scope run"

git push

