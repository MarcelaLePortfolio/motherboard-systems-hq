
#!/usr/bin/env bash

set -euo pipefail

REPORT="retention-manager-directory-units-install-$(date +%Y%m%d_%H%M%S).md"

SYSTEM_DIR="$HOME/motherboard-backup-system"

MANAGER="$SYSTEM_DIR/snapshot-manager-prod.sh"

BACKUP_COPY="$SYSTEM_DIR/snapshot-manager-prod.sh.pre-directory-units-$(date +%Y%m%d_%H%M%S)"

DOMAIN="gui/$(id -u)"

LABEL="com.motherboard.snapshot.retention"

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

is_backup_file() {

  case "$1" in

    *.tar.gz|*.bundle) return 0 ;;

    *) return 1 ;;

  esac

}

dir_has_backup_file() {

  find "$1" -type f -print 2>/dev/null | while IFS= read -r f; do

    if is_backup_file "$f"; then

      echo yes

      break

    fi

  done | grep -q yes

}

for BASE in "/Volumes/Rio Drive/backups" "/Volumes/Rio Drive/Motherboard_External_Backup/snapshots" "/Users/marcela-dev/Projects/motherboard-systems-hq-clean/backups"; do

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

  UNIT_LIST="$SYSTEM_DIR/.retention-units-$(echo "$BASE" | shasum -a 256 | awk '{print $1}').txt"

  : > "$UNIT_LIST"

  find "$BASE" -mindepth 1 -maxdepth 1 -print 2>/dev/null | while IFS= read -r p; do

    if [ -f "$p" ] && is_backup_file "$p"; then

      mt="$(stat -f %m "$p" 2>/dev/null || echo 0)"

      sz="$(stat -f %z "$p" 2>/dev/null || echo 0)"

      echo "$mt $sz FILE $p" >> "$UNIT_LIST"

    elif [ -d "$p" ] && dir_has_backup_file "$p"; then

      mt="$(stat -f %m "$p" 2>/dev/null || echo 0)"

      sz="$(du -sk "$p" 2>/dev/null | awk '{print $1 * 1024}')"

      echo "$mt $sz DIR $p" >> "$UNIT_LIST"

    fi

  done

  sort -n "$UNIT_LIST" -o "$UNIT_LIST"

  COUNT=$(wc -l < "$UNIT_LIST" | tr -d ' ')

  TOTAL_SCANNED=$((TOTAL_SCANNED + COUNT))

  if [ "$COUNT" -le "$KEEP_NEWEST_PER_ROOT" ] && [ "${ROOT_BYTES:-0}" -le "$MAX_BYTES" ]; then

    continue

  fi

  DELETE_LIMIT=$((COUNT - KEEP_NEWEST_PER_ROOT))

  [ "$DELETE_LIMIT" -lt 0 ] && DELETE_LIMIT=0

  INDEX=0

  while IFS= read -r row; do

    mt="$(echo "$row" | awk '{print $1}')"

    sz="$(echo "$row" | awk '{print $2}')"

    kind="$(echo "$row" | awk '{print $3}')"

    path="$(echo "$row" | cut -d' ' -f4-)"

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

        "$BASE"/*)

          echo "DELETE_$kind $sz $path" >> "$PLAN_FILE"

          if [ "$kind" = "FILE" ]; then

            rm -f "$path"

          elif [ "$kind" = "DIR" ]; then

            rm -rf "$path"

          else

            SAFETY_BLOCKED=$((SAFETY_BLOCKED + 1))

          fi

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

  done < "$UNIT_LIST"

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

  "mode": "safe_autonomous_directory_unit_retention",

  "archive_old_backups": false,

  "compress_old_backups": false,

  "delete_known_backup_units_only": true,

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

echo "=== DONE $VERDICT scanned=$TOTAL_SCANNED deleted=$TOTAL_DELETED bytes_deleted=$TOTAL_BYTES_DELETED ===" >> "$LOG_FILE"

MANAGER_EOF

chmod +x "$MANAGER"

: > "$SYSTEM_DIR/launchd.out.log"

: > "$SYSTEM_DIR/launchd.err.log"

bash -n "$MANAGER"

launchctl kickstart -k "$DOMAIN/$LABEL" || true

sleep 5

{

  echo "# Retention Manager Directory Units Install"

  echo

  echo "Backup copy: $BACKUP_COPY"

  echo

  echo "## Archive-loop commands remaining"

  grep -nE "archive_name|tar -czf|gzip|zip|mapfile" "$MANAGER" || true

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

} > "$REPORT"

cat "$REPORT"

git add "$REPORT" install-retention-manager-directory-units.sh

git commit -m "Install directory unit retention manager"

git push

