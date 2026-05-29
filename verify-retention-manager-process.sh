
#!/usr/bin/env bash

set -euo pipefail

REPORT="retention-manager-process-verification-$(date +%Y%m%d_%H%M%S).md"

DOMAIN="gui/$(id -u)"

LABEL="com.motherboard.snapshot.retention"

PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

MANAGER="$HOME/motherboard-backup-system/snapshot-manager-prod.sh"

ROOT="$HOME/motherboard-backup-system"

{

  echo "# Retention Manager Process Verification"

  echo

  echo "Repo: $(git rev-parse --show-toplevel)"

  echo "Branch: $(git branch --show-current)"

  echo "HEAD: $(git rev-parse HEAD)"

  echo

  echo "## LaunchAgent Status"

  echo

  launchctl print "$DOMAIN/$LABEL" 2>&1 || true

  echo

  echo "## Plist"

  echo

  cat "$PLIST" 2>/dev/null || true

  echo

  echo "## Manager Path"

  echo

  ls -la "$ROOT" 2>/dev/null || true

  echo

  echo "## Manager Script"

  echo

  ls -l "$MANAGER" 2>/dev/null || true

  echo

  echo "## Manager Syntax"

  echo

  bash -n "$MANAGER" 2>&1 || true

  echo

  echo "## Manager Script Preview"

  echo

  sed -n '1,220p' "$MANAGER" 2>/dev/null || true

  echo

  echo "## Manager Logs"

  echo

  echo "stdout:"

  tail -120 "$ROOT/launchd.out.log" 2>/dev/null || true

  echo

  echo "stderr:"

  tail -120 "$ROOT/launchd.err.log" 2>/dev/null || true

  echo

  echo "## Disk Safety Snapshot"

  echo

  df -h .

  echo

  df -h "/Volumes/Rio Drive" 2>/dev/null || true

  echo

  du -sh backups 2>/dev/null || true

  du -sh "/Volumes/Rio Drive/Motherboard_External_Backup" 2>/dev/null || true

} > "$REPORT"

cat "$REPORT"

git add "$REPORT" verify-retention-manager-process.sh

git commit -m "Verify retention manager process"

git push

