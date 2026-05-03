#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 487 NEXT LIVE SURFACE PROBE ==="

LOG_PATH="docs/phase487_next_live_surface_probe_output.txt"
PID_FILE="/tmp/phase487_next_live_surface_probe.pid"
: > "$LOG_PATH"

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

echo "=== Starting server.ts via tsx ===" | tee -a "$LOG_PATH"
npx tsx server.ts >> "$LOG_PATH" 2>&1 &
SERVER_PID=$!
echo "$SERVER_PID" > "$PID_FILE"

sleep 3

echo | tee -a "$LOG_PATH"
echo "=== Port 3001 listener check ===" | tee -a "$LOG_PATH"
lsof -nP -iTCP:3001 -sTCP:LISTEN | tee -a "$LOG_PATH" || true

echo | tee -a "$LOG_PATH"
echo "=== GET /delegate (control) ===" | tee -a "$LOG_PATH"
curl -sS -m 5 -i "http://127.0.0.1:3001/delegate" | sed -n '1,40p' | tee -a "$LOG_PATH" || true

echo | tee -a "$LOG_PATH"
echo "=== GET /diagnostics/systemHealth (control) ===" | tee -a "$LOG_PATH"
curl -sS -m 5 -i "http://127.0.0.1:3001/diagnostics/systemHealth" | sed -n '1,40p' | tee -a "$LOG_PATH" || true

echo | tee -a "$LOG_PATH"
echo "=== POST /delegate ===" | tee -a "$LOG_PATH"
curl -sS -m 5 -i \
  -X POST "http://127.0.0.1:3001/delegate" \
  -H 'Content-Type: application/json' \
  -d '{"task":"phase487 bounded probe"}' \
  | sed -n '1,80p' | tee -a "$LOG_PATH" || true

echo | tee -a "$LOG_PATH"
echo "=== POST /matilda ===" | tee -a "$LOG_PATH"
curl -sS -m 5 -i \
  -X POST "http://127.0.0.1:3001/matilda" \
  -H 'Content-Type: application/json' \
  -d '{"message":"hello"}' \
  | sed -n '1,80p' | tee -a "$LOG_PATH" || true

echo | tee -a "$LOG_PATH"
echo "=== Tail of startup log ===" | tee -a "$LOG_PATH"
tail -80 "$LOG_PATH"
