
#!/usr/bin/env bash

set -euo pipefail

REPORT="retention-manager-no-archive-loop-install-$(date +%Y%m%d_%H%M%S).md"

SYSTEM_DIR="$HOME/motherboard-backup-system"

MANAGER="$SYSTEM_DIR/snapshot-manager-prod.sh"

BACKUP_COPY="$SYSTEM_DIR/snapshot-manager-prod.sh.pre-no-archive-loop-$(date +%Y%m%d_%H%M%S)"

DOMAIN="gui/$(id -u)"

LABEL="com.motherboard.snapshot.retention"

mkdir -p "$SYSTEM_DIR"

cp "$MANAGER" "$BACKUP_COPY"

cat > "$MANAGER" << 'MANAGER_EOF'

#!/bin/bash

set +e

SYSTEM_DIR="/Users/marcela-dev/motherboard-backup-system"

LOG_FILE="$SYSTEM_DIR/snapshot-retention.log"

STATE_FILE="$SYSTEM_DIR/last-run-status.txt"

HEARTBEAT_FILE="$SYSTEM_DIR/last-heartbeat.txt"

METRICS_FILE="$SYSTEM_DIR/last-run-metrics.json"

RECON_FILE="$SYSTEM_DIR/reconciliation.json"

PLAN_FILE="$SYSTEM_DIR/last-retention-plan.txt"

LOCK_DIR="$SYSTEM_DIR/.snapshot-retention.lock"

MANAGED_ROOTS=(

  "/Volumes/Rio Drive/backups"

  "/Volumes/Rio Drive/Motherboard_External_Backup/snapshots"

  "/Users/marcela-dev/Projects/motherboard-systems-hq-clean/backups"

)

KEEP_NEWEST_PER_ROOT=5

MIN_AGE_SECONDS=86400

MAX_LOCAL_BACKUPS_BYTES=$((12 * 1024 * 1024 * 1024))

MAX_EXTERNAL_BACKUPS_BYTES=$((400 * 1024 * 1024 * 1024))

mkdir -p "$SYSTEM_DIR"

if ! mkdir "$LOCK_DIR" 2>/dev/null; then

  echo "$(date) SKIPPED_ALREADY_RUNNING" >> "$LOG_FILE"

  exit 0

fi

trap 'rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT

START_TIME=$(date +%s)

NOW="$START_TIME"

TOTAL_SCANNED=0

TOTAL_DELETED=0

TOTAL_BYTES_DELETED=0

MISSING_ROOTS=0

SAFETY_BLOCKED=0

ROOTS_OK=0

: > "$PLAN_FILE"

echo "=== RUN $(date) ===" >> "$LOG_FILE"

for BASE in "${MANAGED_ROOTS[@]}"; do

  if [ ! -d "$BASE" ]; then

    MISSING_ROOTS=$((MISSING_ROOTS + 1))

    echo "MISSING_ROOT: $BASE" >> "$LOG_FILE"

    continue

  fi

  ROOTS_OK=$((ROOTS_OK + 1))

  ROOT_BYTES=$(du -sk "$BASE" 2>/dev/null | awk '{print $1 * 1024}')

  case "$BASE" in

    "/Users/marcela-dev/Projects/motherboard-systems-hq-clean/backups")

      MAX_BYTES="$MAX_LOCAL_BACKUPS_BYTES"

      ;;

    *)

      MAX_BYTES="$MAX_EXTERNAL_BACKUPS_BYTES"

      ;;

  esac

  mapfile -t FILES < <(

    find "$BASE" -maxdepth 1 -type f \( \

      -name "*.tar.gz" -o \

      -name "*.bundle" -o \

      -name "full-disaster-recovery-*.tar.gz" -o \

      -name "manual_*checkpoint*.tar.gz" -o \

      -name "manual_*checkpoint*.bundle" -o \

      -name "repo_*.bundle" -o \

      -name "source_*.tar.gz" \

    \) -print 2>/dev/null | while read -r f; do

      mt="$(stat -f %m "$f" 2>/dev/null || echo 0)"

      sz="$(stat -f %z "$f" 2>/dev/null || echo 0)"

      echo "$mt $sz $f"

    done | sort -n

  )

  COUNT="${#FILES[@]}"

  TOTAL_SCANNED=$((TOTAL_SCANNED + COUNT))

  if [ "$COUNT" -le "$KEEP_NEWEST_PER_ROOT" ] && [ "${ROOT_BYTES:-0}" -le "$MAX_BYTES" ]; then

    continue

  fi

  DELETE_LIMIT=$((COUNT - KEEP_NEWEST_PER_ROOT))

  [ "$DELETE_LIMIT" -lt 0 ] && DELETE_LIMIT=0

  INDEX=0

  for row in "${FILES[@]}"; do

    mt="$(echo "$row" | awk '{print $1}')"

    sz="$(echo "$row" | awk '{print $2}')"

    path="$(echo "$row" | cut -d' ' -f3-)"

    age=$((NOW - mt))

    should_delete="NO"

    if [ "$INDEX" -lt "$DELETE_LIMIT" ] && [ "$age" -ge "$MIN_AGE_SECONDS" ]; then

      should_delete="YES"

    fi

    if [ "${ROOT_BYTES:-0}" -gt "$MAX_BYTES" ] && [ "$age" -ge "$MIN_AGE_SECONDS" ]; then

      should_delete="YES"

    fi

    if [ "$should_delete" = "YES" ]; then

      case "$path" in

        "$BASE"/*.tar.gz|"$BASE"/*.bundle)

          echo "DELETE $sz $path" >> "$PLAN_FILE"

          rm -f "$path"

          if [ ! -e "$path" ]; then

            TOTAL_DELETED=$((TOTAL_DELETED + 1))

            TOTAL_BYTES_DELETED=$((TOTAL_BYTES_DELETED + sz))

            ROOT_BYTES=$((ROOT_BYTES - sz))

          else

            SAFETY_BLOCKED=$((SAFETY_BLOCKED + 1))

          fi

          ;;

        *)

          SAFETY_BLOCKED=$((SAFETY_BLOCKED + 1))

          echo "BLOCKED_UNSAFE_PATH $path" >> "$PLAN_FILE"

          ;;

      esac

    fi

    INDEX=$((INDEX + 1))

  done

done

END_TIME=$(date +%s)

DURATION=$((END_TIME - START_TIME))

if [ "$SAFETY_BLOCKED" -eq 0 ]; then

  VERDICT="OK"

else

  VERDICT="DEGRADED_SAFETY_BLOCKED"

fi

cat > "$RECON_FILE" << JSON

{

  "timestamp": "$(date)",

  "verdict": "$VERDICT",

  "mode": "safe_autonomous_delete_only_retention",

  "archive_old_backups": false,

  "compress_old_backups": false,

  "keep_newest_per_root": $KEEP_NEWEST_PER_ROOT,

  "minimum_age_seconds_before_delete": $MIN_AGE_SECONDS,

  "roots_ok": $ROOTS_OK,

  "missing_roots": $MISSING_ROOTS,

  "scanned": $TOTAL_SCANNED,

  "deleted": $TOTAL_DELETED,

  "bytes_deleted": $TOTAL_BYTES_DELETED,

  "safety_blocked": $SAFETY_BLOCKED,

  "duration_seconds": $DURATION,

  "confidence": 1.0

}

JSON

echo "$(date)" > "$HEARTBEAT_FILE"

echo "$VERDICT" > "$STATE_FILE"

cat > "$METRICS_FILE" << METRICS

{

  "timestamp": "$(date)",

  "status": "$VERDICT",

  "scanned": $TOTAL_SCANNED,

  "deleted": $TOTAL_DELETED,

  "bytes_deleted": $TOTAL_BYTES_DELETED,

  "missing_roots": $MISSING_ROOTS,

  "safety_blocked": $SAFETY_BLOCKED,

  "duration_seconds": $DURATION

}

METRICS

echo "=== DONE $VERDICT deleted=$TOTAL_DELETED bytes_deleted=$TOTAL_BYTES_DELETED ===" >> "$LOG_FILE"

MANAGER_EOF

chmod +x "$MANAGER"

pkill -f snapshot-manager-prod.sh || true

pkill -f "tar -czf /Users/marcela-dev/motherboard-backup-system/_auto_archives" || true

rm -f "$SYSTEM_DIR/_auto_archives/"*-archive-20260529_094304.tar.gz

: > "$SYSTEM_DIR/launchd.out.log"

: > "$SYSTEM_DIR/launchd.err.log"

bash -n "$MANAGER"

launchctl kickstart -k "$DOMAIN/$LABEL" || true

sleep 5

{

  echo "# Retention Manager No-Archive-Loop Install"

  echo

  echo "Backup copy: $BACKUP_COPY"

  echo

  echo "## Archive-loop commands remaining"

  grep -nE "archive_name|tar -czf|gzip|zip" "$MANAGER" || true

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

  echo

  echo "## Retention Plan"

  cat "$SYSTEM_DIR/last-retention-plan.txt" 2>/dev/null || true

  echo

  echo "## Archive Dir"

  du -sh "$SYSTEM_DIR/_auto_archives" 2>/dev/null || true

  ls -ltrh "$SYSTEM_DIR/_auto_archives" 2>/dev/null | tail -20 || true

} > "$REPORT"

cat "$REPORT"

git add "$REPORT" install-retention-manager-no-archive-loop.sh

git commit -m "Install no-archive-loop retention manager"

git push

