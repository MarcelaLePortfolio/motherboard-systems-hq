
#!/usr/bin/env bash

set -euo pipefail

REPORT="nightly-disaster-backup-executor-disabled-$(date +%Y%m%d_%H%M%S).md"

LABEL="com.motherboard.disaster.backup"

PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

DOMAIN="gui/$(id -u)"

{

  echo "# Nightly Disaster Backup Executor Disabled"

  echo

  echo "Repo: $(git rev-parse --show-toplevel)"

  echo "Branch: $(git branch --show-current)"

  echo "HEAD: $(git rev-parse HEAD)"

  echo

  echo "## Reason"

  echo

  echo "Manual disaster backup execution now succeeds."

  echo "The scheduled LaunchAgent execution path still hits macOS external-volume permission denial."

  echo "Because nightly backups are not desired, the clean resolution is to disable the scheduled disaster-backup executor rather than keep a failing automatic job."

  echo

  echo "## Before"

  echo

  launchctl print "$DOMAIN/$LABEL" 2>&1 || true

  echo

} > "$REPORT"

launchctl bootout "$DOMAIN" "$PLIST" 2>/dev/null || true

launchctl disable "$DOMAIN/$LABEL" 2>/dev/null || true

{

  echo

  echo "## After"

  echo

  launchctl print "$DOMAIN/$LABEL" 2>&1 || true

  echo

  echo "## Fixed Manual Backup Script"

  echo

  ls -l scripts/disaster-recovery/create-phase736-external-backup.sh

  echo

  echo "## Latest Successful Manual Snapshot"

  echo

  ls -ltrh "/Volumes/Rio Drive/Motherboard_External_Backup/snapshots" | tail -10 || true

  echo

  echo "## Retention Manager Status"

  echo

  launchctl print "$DOMAIN/com.motherboard.snapshot.retention" 2>&1 || true

} >> "$REPORT"

cat "$REPORT"

git add "$REPORT" disable-nightly-disaster-backup-executor.sh

git commit -m "Disable unwanted nightly disaster backup executor"

git push

