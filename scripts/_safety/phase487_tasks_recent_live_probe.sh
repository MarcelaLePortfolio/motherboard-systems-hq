#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 487 /tasks/recent LIVE PROBE ==="

LOG_PATH="docs/phase487_tasks_recent_live_probe_output.txt"
PID_FILE="/tmp/phase487_tasks_recent_live_probe.pid"
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
echo "=== /tasks/recent probe ===" | tee -a "$LOG_PATH"
curl -sS -m 3 -i "http://127.0.0.1:3001/tasks/recent" | sed -n '1,60p' | tee -a "$LOG_PATH" || true

echo | tee -a "$LOG_PATH"
echo "=== /logs/recent probe ===" | tee -a "$LOG_PATH"
curl -sS -m 3 -i "http://127.0.0.1:3001/logs/recent" | sed -n '1,40p' | tee -a "$LOG_PATH" || true

echo | tee -a "$LOG_PATH"
echo "=== Tail of startup log ===" | tee -a "$LOG_PATH"
tail -60 "$LOG_PATH"
