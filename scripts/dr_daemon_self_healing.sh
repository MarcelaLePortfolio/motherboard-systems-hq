
#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

LOG_FILE="$ROOT_DIR/backups/dr_daemon.log"

EXTERNAL="/Volumes/Rio Drive"

mkdir -p "$ROOT_DIR/backups"

log() {

  echo "[$(date)] $1" >> "$LOG_FILE"

}

run_cycle() {

  log "CYCLE START"

  # 1. WAIT FOR DRIVE (SELF-HEAL)

  until [ -d "$EXTERNAL" ]; do

    log "WAITING FOR EXTERNAL DRIVE..."

    sleep 10

  done

  # 2. STORAGE CHECK

  bash "$ROOT_DIR/scripts/storage_monitor.sh" >> "$LOG_FILE" 2>&1 || true

  bash "$ROOT_DIR/scripts/storage_policy.sh"

  POLICY=$?

  if [ "$POLICY" -eq 2 ]; then

    log "CRITICAL POLICY → RETENTION ENGINE"

    bash "$ROOT_DIR/scripts/retention_engine.sh" >> "$LOG_FILE" 2>&1 || true

  fi

  # 3. BACKUP WITH SELF-HEAL RETRY (ONCE)

  if ! bash "$ROOT_DIR/scripts/full_dr_pipeline.sh" >> "$LOG_FILE" 2>&1; then

    log "BACKUP FAILED → RETRYING ONCE"

    sleep 5

    bash "$ROOT_DIR/scripts/full_dr_pipeline.sh" >> "$LOG_FILE" 2>&1 || true

  fi

  log "CYCLE COMPLETE"

}

log "SELF-HEALING DAEMON STARTED"

while true; do

  run_cycle

  # heartbeat every 60 minutes

  sleep 3600

done

