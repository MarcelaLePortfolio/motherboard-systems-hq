
#!/usr/bin/env bash

set -euo pipefail

REPO="$(git rev-parse --show-toplevel)"

REPORT="disaster-backup-retention-health-$(date +%Y%m%d_%H%M%S).md"

EXTERNAL="/Volumes/Rio Drive/Motherboard_External_Backup"

{

  echo "# Disaster Backup + Retention Health Verification"

  echo

  echo "Repo: $REPO"

  echo "External backup root: $EXTERNAL"

  echo "Timestamp: $(date)"

  echo

  echo "## LaunchAgents"

  echo

  launchctl print "gui/$(id -u)/com.motherboard.disaster.backup" 2>&1 | sed -n '1,120p' || true

  echo

  echo "--------------------------------"

  echo

  launchctl print "gui/$(id -u)/com.motherboard.snapshot.retention" 2>&1 | sed -n '1,120p' || true

  echo

  echo "## Backup Logs"

  echo

  echo "### stdout"

  tail -120 "$REPO/logs/disaster-backup.out.log" 2>/dev/null || true

  echo

  echo "### stderr"

  tail -120 "$REPO/logs/disaster-backup.err.log" 2>/dev/null || true

  echo

  echo "## Retention Logs"

  echo

  find "$REPO" "$EXTERNAL" -type f \( -iname "*retention*.log" -o -iname "*prune*.log" -o -iname "*dr_daemon*.log" \) -maxdepth 5 -print 2>/dev/null || true

  echo

  echo "## Recent External Snapshots"

  echo

  ls -ltrh "$EXTERNAL/snapshots" 2>/dev/null | tail -30 || true

  echo

  echo "## Latest Snapshot Contents"

  echo

  LATEST="$(find "$EXTERNAL/snapshots" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null | sort | tail -1 || true)"

  echo "Latest snapshot: ${LATEST:-NONE}"

  if [ -n "${LATEST:-}" ]; then

    find "$LATEST" -maxdepth 2 -type f -print | sort

    echo

    du -sh "$LATEST" || true

  fi

  echo

  echo "## Disk Usage"

  echo

  df -h .

  echo

  df -h "$EXTERNAL" || true

  echo

  du -sh backups 2>/dev/null || true

  du -sh "$EXTERNAL" 2>/dev/null || true

} > "$REPORT"

cat "$REPORT"

git add "$REPORT" verify-disaster-backup-and-retention-health.sh

git commit -m "Verify disaster backup and retention health"

git push

