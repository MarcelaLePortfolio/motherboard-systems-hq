#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://127.0.0.1:3000}"
PORT="${2:-3000}"

OUTPUT_FILE="PHASE88_14_8_FORCE_RESTART_AND_VERIFY.txt"
BOOT_LOG="PHASE88_14_8_SERVER_RESTART.log"
PID_FILE=".phase88_14_8_server.pid"

PRIMARY_HEADERS="PHASE88_14_8_SYSTEM_HEALTH_PRIMARY_HEADERS.txt"
PRIMARY_JSON="PHASE88_14_8_SYSTEM_HEALTH_PRIMARY_RESPONSE.json"
ALIAS_HEADERS="PHASE88_14_8_SYSTEM_HEALTH_ALIAS_HEADERS.txt"
ALIAS_JSON="PHASE88_14_8_SYSTEM_HEALTH_ALIAS_RESPONSE.json"

kill_port_processes() {
  local port="$1"
  if command -v lsof >/dev/null 2>&1; then
    mapfile -t pids < <(lsof -ti tcp:"$port" || true)
    if [[ "${#pids[@]}" -gt 0 ]]; then
      kill "${pids[@]}" || true
      sleep 2
      mapfile -t remaining < <(lsof -ti tcp:"$port" || true)
      if [[ "${#remaining[@]}" -gt 0 ]]; then
        kill -9 "${remaining[@]}" || true
        sleep 1
      fi
    fi
  fi
}

wait_for_url() {
  local url="$1"
  local attempts="${2:-30}"
  local delay="${3:-1}"

  for _ in $(seq 1 "$attempts"); do
    if curl -fsS "$url" >/dev/null 2>&1; then
      return 0
    fi
    sleep "$delay"
  done

  return 1
}

kill_port_processes "$PORT"

nohup node server.mjs > "$BOOT_LOG" 2>&1 &
echo $! > "$PID_FILE"

wait_for_url "$BASE_URL/dashboard" 30 1

curl -sS -D "$PRIMARY_HEADERS" -o "$PRIMARY_JSON" "$BASE_URL/diagnostics/system-health"
curl -sS -D "$ALIAS_HEADERS" -o "$ALIAS_JSON" "$BASE_URL/diagnostics/systemHealth"

python3 - << 'PY'
import json
from pathlib import Path

def status_code(path: str) -> int:
    first = Path(path).read_text().splitlines()[0]
    return int(first.split()[1])

primary_status = status_code("PHASE88_14_8_SYSTEM_HEALTH_PRIMARY_HEADERS.txt")
alias_status = status_code("PHASE88_14_8_SYSTEM_HEALTH_ALIAS_HEADERS.txt")

assert primary_status == 200, f"Expected 200 on primary route, got {primary_status}"
assert alias_status == 200, f"Expected 200 on alias route, got {alias_status}"

primary = json.loads(Path("PHASE88_14_8_SYSTEM_HEALTH_PRIMARY_RESPONSE.json").read_text())
alias = json.loads(Path("PHASE88_14_8_SYSTEM_HEALTH_ALIAS_RESPONSE.json").read_text())

assert primary["status"] == "OK", "Expected status OK on primary route"
assert alias["status"] == "OK", "Expected status OK on alias route"
assert "situationSummary" in primary, "Expected situationSummary on primary route"
assert "situationSummary" in alias, "Expected situationSummary on alias route"
assert "SYSTEM STABLE" in primary["situationSummary"], "Expected stable summary on primary route"
assert "SYSTEM STABLE" in alias["situationSummary"], "Expected stable summary on alias route"
PY

{
  echo "PHASE 88.14.8 FORCE RESTART AND VERIFY"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "Base URL: $BASE_URL"
  echo "Port: $PORT"
  echo "Server PID: $(cat "$PID_FILE")"
  echo "Boot Log: $BOOT_LOG"
  echo "────────────────────────────────"
  echo "PRIMARY HEADERS:"
  cat "$PRIMARY_HEADERS"
  echo "────────────────────────────────"
  echo "PRIMARY RESPONSE:"
  cat "$PRIMARY_JSON"
  echo
  echo "────────────────────────────────"
  echo "ALIAS HEADERS:"
  cat "$ALIAS_HEADERS"
  echo "────────────────────────────────"
  echo "ALIAS RESPONSE:"
  cat "$ALIAS_JSON"
  echo
  echo "────────────────────────────────"
  echo "SERVER MOUNT HITS:"
  rg -n 'systemHealthRouter|diagnostics/system-health|diagnostics/systemHealth' server.mjs
  echo "────────────────────────────────"
  echo "RESULT: PASS"
} | tee "$OUTPUT_FILE"
