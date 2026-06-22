
#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

LOG_FILE="$ROOT_DIR/backups/dr_daemon.log"

mkdir -p "$ROOT_DIR/backups"

echo "DR DAEMON STARTED: $(date)" >> "$LOG_FILE"

while true; do

  echo "----------------------------------------" >> "$LOG_FILE"

  echo "CYCLE START: $(date)" >> "$LOG_FILE"

  # run storage monitor

  bash "$ROOT_DIR/scripts/storage_monitor.sh" >> "$LOG_FILE" 2>&1 || true

  # run policy check

  bash "$ROOT_DIR/scripts/storage_policy.sh" >> "$LOG_FILE" 2>&1

  POLICY=$?

  # always run backup if drive exists

  if [ $POLICY -ne 0 ]; then

    echo "POLICY TRIGGERED RETENTION" >> "$LOG_FILE"

    bash "$ROOT_DIR/scripts/retention_engine.sh" >> "$LOG_FILE" 2>&1 || true

  fi

  echo "RUNNING BACKUP" >> "$LOG_FILE"

  bash "$ROOT_DIR/scripts/full_dr_pipeline.sh" >> "$LOG_FILE" 2>&1 || true

  echo "CYCLE COMPLETE: $(date)" >> "$LOG_FILE"

  # sleep 1 hour

  sleep 3600

done

