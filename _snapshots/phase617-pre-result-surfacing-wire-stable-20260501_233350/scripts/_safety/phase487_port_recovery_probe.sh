#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 487 PORT RECOVERY PROBE ==="

echo
echo "=== 1) Check if anything is listening on 3001 ==="
lsof -nP -iTCP:3001 -sTCP:LISTEN || true

echo
echo "=== 2) Kill any stale server.ts processes ==="
pkill -f "tsx server.ts" 2>/dev/null || true
sleep 1

echo
echo "=== 3) Start server fresh ==="
LOG_PATH="docs/phase487_port_recovery_probe_output.txt"
: > "$LOG_PATH"

npx tsx server.ts >> "$LOG_PATH" 2>&1 &
SERVER_PID=$!
echo "SERVER_PID=$SERVER_PID"

sleep 3

echo
echo "=== 4) Confirm listener ==="
lsof -nP -iTCP:3001 -sTCP:LISTEN || true

echo
echo "=== 5) Probe root ==="
curl -sS -i http://127.0.0.1:3001 | sed -n '1,40p' || true

echo
echo "=== 6) Probe diagnostics ==="
curl -sS -i http://127.0.0.1:3001/diagnostics/systemHealth | sed -n '1,40p' || true

echo
echo "=== 7) Tail logs ==="
tail -60 "$LOG_PATH"

echo
echo "=== END PORT RECOVERY PROBE ==="
