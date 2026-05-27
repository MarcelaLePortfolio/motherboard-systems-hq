#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE88_14_6_MOUNT_FAILURE_STATE.txt"
BOOT_LOG="PHASE88_14_5_SERVER_RESTART.log"
PID_FILE=".phase88_14_5_server.pid"
BASE_URL="${1:-http://127.0.0.1:3000}"

{
  echo "PHASE 88.14.6 MOUNT FAILURE STATE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "Base URL: $BASE_URL"
  echo "────────────────────────────────"

  echo "SECTION: server.mjs mount lines"
  rg -n 'systemHealthRouter|diagnostics/system-health|diagnostics/systemHealth|apiTasksMutationsRouter' server.mjs || true
  echo "────────────────────────────────"

  echo "SECTION: server.mjs import block head"
  sed -n '1,80p' server.mjs
  echo "────────────────────────────────"

  echo "SECTION: server.mjs mount area"
  sed -n '168,190p' server.mjs
  echo "────────────────────────────────"

  echo "SECTION: PID status"
  if [[ -f "$PID_FILE" ]]; then
    PID="$(cat "$PID_FILE" || true)"
    echo "PID_FILE: $PID_FILE"
    echo "PID: ${PID:-<empty>}"
    if [[ -n "${PID:-}" ]] && kill -0 "$PID" 2>/dev/null; then
      echo "PROCESS: alive"
      ps -p "$PID" -o pid=,ppid=,stat=,etime=,command=
    else
      echo "PROCESS: not running"
    fi
  else
    echo "PID file not present"
  fi
  echo "────────────────────────────────"

  echo "SECTION: boot log tail"
  if [[ -f "$BOOT_LOG" ]]; then
    tail -n 120 "$BOOT_LOG"
  else
    echo "Boot log not present"
  fi
  echo "────────────────────────────────"

  echo "SECTION: live route probes"
  for url in \
    "$BASE_URL/diagnostics/system-health" \
    "$BASE_URL/diagnostics/systemHealth" \
    "$BASE_URL/dashboard"
  do
    echo "URL: $url"
    curl -i -sS "$url" | sed -n '1,40p' || true
    echo "────────────────────────────────"
  done
} | tee "$OUTPUT_FILE"
