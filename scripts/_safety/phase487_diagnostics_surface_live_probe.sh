#!/usr/bin/env bash
set -euo pipefail

LOG_PATH="docs/phase487_diagnostics_surface_live_probe_output.txt"
PID_FILE="/tmp/phase487_diag.pid"
: > "$LOG_PATH"

cleanup() {
  if [ -f "$PID_FILE" ]; then
    PID="$(cat "$PID_FILE")"
    kill "$PID" 2>/dev/null || true
    wait "$PID" 2>/dev/null || true
    rm -f "$PID_FILE"
  fi
}
trap cleanup EXIT

npx tsx server.ts >> "$LOG_PATH" 2>&1 &
echo $! > "$PID_FILE"

sleep 3

curl -sS -i http://127.0.0.1:3001/diagnostics/systemHealth | tee -a "$LOG_PATH"
curl -sS -i http://127.0.0.1:3001/tasks/recent | tee -a "$LOG_PATH"
curl -sS -i http://127.0.0.1:3001/logs/recent | tee -a "$LOG_PATH"

tail -50 "$LOG_PATH"
