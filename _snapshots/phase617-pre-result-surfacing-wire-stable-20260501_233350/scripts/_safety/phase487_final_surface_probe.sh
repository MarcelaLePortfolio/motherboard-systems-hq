#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 487 FINAL SURFACE PROBE ==="

LOG_PATH="docs/phase487_final_surface_probe_output.txt"
PID_FILE="/tmp/phase487_final_surface_probe.pid"
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
echo "=== /tasks/recent ===" | tee -a "$LOG_PATH"
curl -sS -i http://127.0.0.1:3001/tasks/recent | sed -n '1,40p' | tee -a "$LOG_PATH"

echo | tee -a "$LOG_PATH"
echo "=== /logs/recent ===" | tee -a "$LOG_PATH"
curl -sS -i http://127.0.0.1:3001/logs/recent | sed -n '1,40p' | tee -a "$LOG_PATH"

echo | tee -a "$LOG_PATH"
echo "=== POST /delegate ===" | tee -a "$LOG_PATH"
curl -sS -i -X POST http://127.0.0.1:3001/delegate \
  -H "Content-Type: application/json" \
  -d '{"task":"final probe"}' \
  | sed -n '1,60p' | tee -a "$LOG_PATH"

echo | tee -a "$LOG_PATH"
echo "=== POST /matilda ===" | tee -a "$LOG_PATH"
curl -sS -i -X POST http://127.0.0.1:3001/matilda \
  -H "Content-Type: application/json" \
  -d '{"message":"hello"}' \
  | sed -n '1,60p' | tee -a "$LOG_PATH"

echo
echo "=== Tail ==="
tail -80 "$LOG_PATH"
