#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 487 MATILDA LOCAL LIVE PROBE ==="

LOG_PATH="docs/phase487_matilda_local_live_probe_output.txt"
PID_FILE="/tmp/phase487_matilda_local_live_probe.pid"
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

probe() {
  local label="$1"
  local method="$2"
  local path="$3"
  local data="${4:-}"

  echo | tee -a "$LOG_PATH"
  echo "=== $label ===" | tee -a "$LOG_PATH"

  if [ "$method" = "GET" ]; then
    curl -sS -m 5 -i "http://127.0.0.1:3001$path" | sed -n '1,60p' | tee -a "$LOG_PATH" || true
  else
    curl -sS -m 5 -i -X "$method" "http://127.0.0.1:3001$path" \
      -H 'Content-Type: application/json' \
      -d "$data" | sed -n '1,80p' | tee -a "$LOG_PATH" || true
  fi
}

probe "GET /tasks/recent" "GET" "/tasks/recent"
probe "GET /logs/recent" "GET" "/logs/recent"
probe "POST /delegate" "POST" "/delegate" '{"task":"matilda-local-probe"}'
probe "POST /matilda (greeting)" "POST" "/matilda" '{"message":"hello"}'
probe "POST /matilda (status)" "POST" "/matilda" '{"message":"are you there"}'
probe "POST /matilda (general)" "POST" "/matilda" '{"message":"please help me with next steps"}'

echo | tee -a "$LOG_PATH"
echo "=== Tail of startup log ===" | tee -a "$LOG_PATH"
tail -80 "$LOG_PATH"
