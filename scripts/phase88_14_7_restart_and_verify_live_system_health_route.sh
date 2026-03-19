#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE88_14_7_LIVE_SYSTEM_HEALTH_ROUTE_VERIFICATION.txt"
BOOT_LOG="PHASE88_14_7_SERVER_RESTART.log"
PID_FILE=".phase88_14_7_server.pid"
BASE_URL="${1:-http://127.0.0.1:3000}"

PRIMARY_JSON="PHASE88_14_7_SYSTEM_HEALTH_RESPONSE.json"
ALIAS_JSON="PHASE88_14_7_SYSTEM_HEALTH_ALIAS_RESPONSE.json"

if [[ -f .phase88_14_5_server.pid ]]; then
  OLD_PID="$(cat .phase88_14_5_server.pid || true)"
  if [[ -n "${OLD_PID:-}" ]] && kill -0 "$OLD_PID" 2>/dev/null; then
    kill "$OLD_PID" || true
    sleep 2
  fi
fi

if [[ -f "$PID_FILE" ]]; then
  OLD_PID="$(cat "$PID_FILE" || true)"
  if [[ -n "${OLD_PID:-}" ]] && kill -0 "$OLD_PID" 2>/dev/null; then
    kill "$OLD_PID" || true
    sleep 2
  fi
fi

nohup node server.mjs > "$BOOT_LOG" 2>&1 &
echo $! > "$PID_FILE"

for _ in $(seq 1 30); do
  if curl -fsS "$BASE_URL/dashboard" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

curl -fsS "$BASE_URL/diagnostics/system-health" > "$PRIMARY_JSON"
curl -fsS "$BASE_URL/diagnostics/systemHealth" > "$ALIAS_JSON"

python3 - << 'PY'
import json
from pathlib import Path

primary = json.loads(Path("PHASE88_14_7_SYSTEM_HEALTH_RESPONSE.json").read_text())
alias = json.loads(Path("PHASE88_14_7_SYSTEM_HEALTH_ALIAS_RESPONSE.json").read_text())

assert primary["status"] == "OK", "Expected status OK on primary route"
assert alias["status"] == "OK", "Expected status OK on alias route"
assert "situationSummary" in primary, "Expected situationSummary on primary route"
assert "situationSummary" in alias, "Expected situationSummary on alias route"
assert "SYSTEM STABLE" in primary["situationSummary"], "Expected stable summary on primary route"
assert "SYSTEM STABLE" in alias["situationSummary"], "Expected stable summary on alias route"
PY

{
  echo "PHASE 88.14.7 LIVE SYSTEM HEALTH ROUTE VERIFICATION"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "Base URL: $BASE_URL"
  echo "Server PID: $(cat "$PID_FILE")"
  echo "Boot Log: $BOOT_LOG"
  echo "────────────────────────────────"
  echo "PRIMARY ROUTE:"
  cat "$PRIMARY_JSON"
  echo
  echo "────────────────────────────────"
  echo "ALIAS ROUTE:"
  cat "$ALIAS_JSON"
  echo
  echo "────────────────────────────────"
  echo "systemHealth.js import line:"
  sed -n '1,20p' routes/diagnostics/systemHealth.js
  echo "────────────────────────────────"
  echo "RESULT: PASS"
} | tee "$OUTPUT_FILE"
