#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://127.0.0.1:3000}"
PORT="${2:-3000}"

OUTPUT_FILE="PHASE88_14_10_LIVE_SYSTEM_HEALTH_AND_DASHBOARD_VERIFICATION.txt"
BOOT_LOG="PHASE88_14_10_SERVER_RESTART.log"
PID_FILE=".phase88_14_10_server.pid"

PRIMARY_HEADERS="PHASE88_14_10_SYSTEM_HEALTH_PRIMARY_HEADERS.txt"
PRIMARY_JSON="PHASE88_14_10_SYSTEM_HEALTH_PRIMARY_RESPONSE.json"
ALIAS_HEADERS="PHASE88_14_10_SYSTEM_HEALTH_ALIAS_HEADERS.txt"
ALIAS_JSON="PHASE88_14_10_SYSTEM_HEALTH_ALIAS_RESPONSE.json"
DASHBOARD_HEADERS="PHASE88_14_10_DASHBOARD_HEADERS.txt"
DASHBOARD_HTML="PHASE88_14_10_DASHBOARD.html"

kill_port_processes() {
  local port="$1"
  local pids=""
  pids="$(lsof -ti tcp:$port 2>/dev/null || true)"

  if [[ -n "$pids" ]]; then
    kill $pids 2>/dev/null || true
    sleep 2

    pids="$(lsof -ti tcp:$port 2>/dev/null || true)"

    if [[ -n "$pids" ]]; then
      kill -9 $pids 2>/dev/null || true
      sleep 1
    fi
  fi
}

wait_for_url() {
  local url="$1"

  for _ in $(seq 1 30); do
    if curl -fsS "$url" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done

  return 1
}

status_code() {
  awk 'NR==1 {print $2}' "$1"
}

kill_port_processes "$PORT"

nohup node server.mjs > "$BOOT_LOG" 2>&1 &
echo $! > "$PID_FILE"

wait_for_url "$BASE_URL/dashboard"

curl -sS -D "$PRIMARY_HEADERS" -o "$PRIMARY_JSON" "$BASE_URL/diagnostics/system-health"
curl -sS -D "$ALIAS_HEADERS" -o "$ALIAS_JSON" "$BASE_URL/diagnostics/systemHealth"
curl -sS -D "$DASHBOARD_HEADERS" -o "$DASHBOARD_HTML" "$BASE_URL/dashboard"

python3 - << 'PY'
import json
from pathlib import Path

def status(path):
    return int(Path(path).read_text().splitlines()[0].split()[1])

assert status("PHASE88_14_10_SYSTEM_HEALTH_PRIMARY_HEADERS.txt") == 200
assert status("PHASE88_14_10_SYSTEM_HEALTH_ALIAS_HEADERS.txt") == 200
assert status("PHASE88_14_10_DASHBOARD_HEADERS.txt") == 200

primary = json.loads(Path("PHASE88_14_10_SYSTEM_HEALTH_PRIMARY_RESPONSE.json").read_text())
alias = json.loads(Path("PHASE88_14_10_SYSTEM_HEALTH_ALIAS_RESPONSE.json").read_text())
dashboard = Path("PHASE88_14_10_DASHBOARD.html").read_text()

for payload in (primary, alias):
    assert payload["status"] == "OK"
    assert "situationSummary" in payload
    assert "SYSTEM STABLE" in payload["situationSummary"]

assert "System Health Diagnostics" in dashboard
assert "system-health-content" in dashboard
assert "/diagnostics/system-health" in dashboard
assert "SITUATION SUMMARY" in dashboard
PY

{
  echo "PHASE 88.14.10 LIVE SYSTEM HEALTH AND DASHBOARD VERIFICATION"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "Server PID: $(cat "$PID_FILE")"
  echo "────────────────────────────────"

  echo "PRIMARY ROUTE STATUS: $(status_code "$PRIMARY_HEADERS")"
  cat "$PRIMARY_JSON"
  echo

  echo "────────────────────────────────"

  echo "ALIAS ROUTE STATUS: $(status_code "$ALIAS_HEADERS")"
  cat "$ALIAS_JSON"
  echo

  echo "────────────────────────────────"

  echo "DASHBOARD STATUS: $(status_code "$DASHBOARD_HEADERS")"
  rg -n 'System Health Diagnostics|system-health-content|SITUATION SUMMARY|/diagnostics/system-health' "$DASHBOARD_HTML"

  echo "────────────────────────────────"
  echo "RESULT: PASS"

} | tee "$OUTPUT_FILE"

