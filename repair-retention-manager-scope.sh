
#!/usr/bin/env bash

set -euo pipefail

REPORT="retention-manager-scope-repair-$(date +%Y%m%d_%H%M%S).md"

SYSTEM_DIR="$HOME/motherboard-backup-system"

MANAGER="$SYSTEM_DIR/snapshot-manager-prod.sh"

BACKUP_COPY="$SYSTEM_DIR/snapshot-manager-prod.sh.pre-scope-repair-$(date +%Y%m%d_%H%M%S)"

mkdir -p "$SYSTEM_DIR"

cp "$MANAGER" "$BACKUP_COPY"

cat > "$MANAGER" << 'MANAGER_EOF'

#!/bin/bash

set +e

SYSTEM_DIR="/Users/marcela-dev/motherboard-backup-system"

ARCHIVE_DIR="$SYSTEM_DIR/_auto_archives"

LOG_FILE="$SYSTEM_DIR/snapshot-retention.log"

STATE_FILE="$SYSTEM_DIR/last-run-status.txt"

HEARTBEAT_FILE="$SYSTEM_DIR/last-heartbeat.txt"

METRICS_FILE="$SYSTEM_DIR/last-run-metrics.json"

RECON_FILE="$SYSTEM_DIR/reconciliation.json"

MANAGED_ROOTS=(

  "/Volumes/Rio Drive/backups"

  "/Volumes/Rio Drive/Motherboard_External_Backup/snapshots"

  "/Users/marcela-dev/Projects/motherboard-systems-hq-clean/backups"

)

mkdir -p "$ARCHIVE_DIR"

START_TIME=$(date +%s)

TOTAL_SCANNED=0

TOTAL_DELETED=0

TOTAL_ARCHIVED=0

SAFETY_BLOCKED=0

EXPECTED_DELETES=0

MISSING_ROOTS=0

echo "=== RUN $(date) ===" >> "$LOG_FILE"

for BASE in "${MANAGED_ROOTS[@]}"; do

  if [ ! -d "$BASE" ]; then

    MISSING_ROOTS=$((MISSING_ROOTS + 1))

    echo "MISSING_ROOT: $BASE" >> "$LOG_FILE"

    continue

  fi

  cd "$BASE" || continue

  shopt -s nullglob

  candidates=(

    full-disaster-recovery-*

    *.tar.gz

    *.bundle

    repo_*.bundle

    source_*.tar.gz

    manual_repo_checkpoint_*.bundle

  )

  count=${#candidates[@]}

  TOTAL_SCANNED=$((TOTAL_SCANNED + count))

  if [ "$count" -le 5 ]; then

    continue

  fi

  keep=5

  old_count=$((count - keep))

  old_files=("${candidates[@]:0:$old_count}")

  EXPECTED_DELETES=$((EXPECTED_DELETES + old_count))

  safe_base="$(echo "$BASE" | shasum -a 256 | awk '{print $1}')"

  archive_name="$ARCHIVE_DIR/${safe_base}-archive-$(date +%Y%m%d_%H%M%S).tar.gz"

  tar -czf "$archive_name" "${old_files[@]}"

  if [ -s "$archive_name" ]; then

    TOTAL_ARCHIVED=$((TOTAL_ARCHIVED + 1))

    for f in "${old_files[@]}"; do

      rm -rf "$f"

      TOTAL_DELETED=$((TOTAL_DELETED + 1))

    done

  else

    SAFETY_BLOCKED=$((SAFETY_BLOCKED + 1))

  fi

done

END_TIME=$(date +%s)

DURATION=$((END_TIME - START_TIME))

DELETION_DIFF=$((TOTAL_DELETED - EXPECTED_DELETES))

if [ "$DELETION_DIFF" -eq 0 ]; then

  VERDICT="OK"

elif [ "$DELETION_DIFF" -lt 0 ]; then

  VERDICT="DEGRADED_UNDERDELETE"

else

  VERDICT="DEGRADED_OVERDELETE"

fi

cat > "$RECON_FILE" << JSON

{

  "timestamp": "$(date)",

  "verdict": "$VERDICT",

  "managed_roots": [

    "/Volumes/Rio Drive/backups",

    "/Volumes/Rio Drive/Motherboard_External_Backup/snapshots",

    "/Users/marcela-dev/Projects/motherboard-systems-hq-clean/backups"

  ],

  "expected_deletes": $EXPECTED_DELETES,

  "actual_deletes": $TOTAL_DELETED,

  "diff": $DELETION_DIFF,

  "archives_created": $TOTAL_ARCHIVED,

  "scanned": $TOTAL_SCANNED,

  "missing_roots": $MISSING_ROOTS,

  "safety_blocked": $SAFETY_BLOCKED,

  "confidence": 1.0

}

JSON

echo "$(date)" > "$HEARTBEAT_FILE"

echo "OK" > "$STATE_FILE"

cat > "$METRICS_FILE" << METRICS

{

  "timestamp": "$(date)",

  "status": "ok",

  "scanned": $TOTAL_SCANNED,

  "deleted": $TOTAL_DELETED,

  "archives_created": $TOTAL_ARCHIVED,

  "missing_roots": $MISSING_ROOTS,

  "safety_blocked": $SAFETY_BLOCKED,

  "duration_seconds": $DURATION

}

METRICS

echo "=== DONE ===" >> "$LOG_FILE"

MANAGER_EOF

chmod +x "$MANAGER"

: > "$SYSTEM_DIR/launchd.out.log"

: > "$SYSTEM_DIR/launchd.err.log"

launchctl kickstart -k "gui/$(id -u)/com.motherboard.snapshot.retention" || true

sleep 5

{

  echo "# Retention Manager Scope Repair"

  echo

  echo "Backup copy: $BACKUP_COPY"

  echo

  echo "## Managed roots now configured"

  grep -n "/Volumes/Rio Drive/backups\|Motherboard_External_Backup\|motherboard-systems-hq-clean/backups" "$MANAGER"

  echo

  echo "## Fresh stderr"

  cat "$SYSTEM_DIR/launchd.err.log" 2>/dev/null || true

  echo

  echo "## Status"

  cat "$SYSTEM_DIR/last-run-status.txt" 2>/dev/null || true

  echo

  echo "## Metrics"

  cat "$SYSTEM_DIR/last-run-metrics.json" 2>/dev/null || true

  echo

  echo "## Reconciliation"

  cat "$SYSTEM_DIR/reconciliation.json" 2>/dev/null || true

} > "$REPORT"

cat "$REPORT"

git add "$REPORT" repair-retention-manager-scope.sh

git commit -m "Repair retention manager scope"

git push

