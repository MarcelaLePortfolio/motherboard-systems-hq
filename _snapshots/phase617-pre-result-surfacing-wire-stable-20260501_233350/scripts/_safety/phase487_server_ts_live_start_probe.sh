#!/usr/bin/env bash
set -euo pipefail

LOG_PATH="docs/phase487_server_ts_live_start_probe_output.txt"
PID_FILE="/tmp/phase487_server_ts_live_start_probe.pid"

: > "$LOG_PATH"

echo "=== PHASE 487 server.ts LIVE START PROBE ===" | tee -a "$LOG_PATH"

cleanup() {
  if [ -f "$PID_FILE" ]; then
    PID="$(cat "$PID_FILE" 2>/dev/null || true)"
    if [ -n "${PID:-}" ] && kill -0 "$PID" 2>/dev/null; then
      kill "$PID" 2>/dev/null || true
      wait "$PID" 2>/dev/null || true
    fi
    rm -f "$PID_FILE"
  fi
}
trap cleanup EXIT

echo | tee -a "$LOG_PATH"
echo "=== Starting server.ts via tsx ===" | tee -a "$LOG_PATH"
npx tsx server.ts >> "$LOG_PATH" 2>&1 &
SERVER_PID=$!
echo "$SERVER_PID" > "$PID_FILE"

sleep 3

echo | tee -a "$LOG_PATH"
echo "=== Port 3001 listener check ===" | tee -a "$LOG_PATH"
lsof -nP -iTCP:3001 -sTCP:LISTEN >> "$LOG_PATH" 2>&1 || true
lsof -nP -iTCP:3001 -sTCP:LISTEN || true

echo | tee -a "$LOG_PATH"
echo "=== /diagnostics/systemHealth probe ===" | tee -a "$LOG_PATH"
curl -sS -m 3 -i "http://127.0.0.1:3001/diagnostics/systemHealth" | tee -a "$LOG_PATH" || true

echo | tee -a "$LOG_PATH"
echo "=== Tail of startup log ===" | tee -a "$LOG_PATH"
tail -40 "$LOG_PATH"
