#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 487 POST-BOOT ROUTE SURFACE AUDIT ==="

LOG_PATH="docs/phase487_post_boot_route_surface_audit_output.txt"
PID_FILE="/tmp/phase487_post_boot_route_surface_audit.pid"
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

echo
echo "=== 1) Mounted route evidence from server.ts ===" | tee -a "$LOG_PATH"
sed -n '1,80p' server.ts | tee -a "$LOG_PATH"

echo | tee -a "$LOG_PATH"
echo "=== 2) Starting bounded live server probe ===" | tee -a "$LOG_PATH"
npx tsx server.ts >> "$LOG_PATH" 2>&1 &
SERVER_PID=$!
echo "$SERVER_PID" > "$PID_FILE"

sleep 3

echo | tee -a "$LOG_PATH"
echo "=== 3) Listener check ===" | tee -a "$LOG_PATH"
lsof -nP -iTCP:3001 -sTCP:LISTEN | tee -a "$LOG_PATH" || true

probe() {
  local path="$1"
  echo | tee -a "$LOG_PATH"
  echo ">>> GET http://127.0.0.1:3001$path" | tee -a "$LOG_PATH"
  curl -sS -m 3 -i "http://127.0.0.1:3001$path" | sed -n '1,40p' | tee -a "$LOG_PATH" || true
}

probe "/"
probe "/tasks/recent"
probe "/logs/recent"
probe "/delegate"
probe "/diagnostics/systemHealth"

echo | tee -a "$LOG_PATH"
echo "=== 4) Tail of live log ===" | tee -a "$LOG_PATH"
tail -60 "$LOG_PATH"
