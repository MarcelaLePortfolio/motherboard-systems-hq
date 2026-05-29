
#!/usr/bin/env bash

set -euo pipefail

REPORT="retention-manager-fresh-run-$(date +%Y%m%d_%H%M%S).md"

DOMAIN="gui/$(id -u)"

LABEL="com.motherboard.snapshot.retention"

ROOT="$HOME/motherboard-backup-system"

: > "$ROOT/launchd.out.log"

: > "$ROOT/launchd.err.log"

launchctl kickstart -k "$DOMAIN/$LABEL" || true

sleep 5

{

  echo "# Retention Manager Fresh Run Verification"

  echo

  echo "## LaunchAgent Status"

  echo

  launchctl print "$DOMAIN/$LABEL" 2>&1 || true

  echo

  echo "## Fresh stderr"

  echo

  cat "$ROOT/launchd.err.log" 2>/dev/null || true

  echo

  echo "## Fresh stdout"

  echo

  cat "$ROOT/launchd.out.log" 2>/dev/null || true

  echo

  echo "## Heartbeat"

  echo

  cat "$ROOT/last-heartbeat.txt" 2>/dev/null || true

  echo

  echo "## Status"

  echo

  cat "$ROOT/last-run-status.txt" 2>/dev/null || true

  echo

  echo "## Metrics"

  echo

  cat "$ROOT/last-run-metrics.json" 2>/dev/null || true

  echo

  echo "## Reconciliation"

  echo

  cat "$ROOT/reconciliation.json" 2>/dev/null || true

} > "$REPORT"

cat "$REPORT"

git add "$REPORT" verify-retention-manager-fresh-run.sh

git commit -m "Verify retention manager fresh run"

git push

