#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://127.0.0.1:3000}"
SYSTEM_HEALTH_URL="$BASE_URL/diagnostics/system-health"
DASHBOARD_URL="$BASE_URL/dashboard"

OUT_JSON="PHASE88_14_LIVE_SYSTEM_HEALTH_RESPONSE.json"
OUT_HTML="PHASE88_14_LIVE_DASHBOARD.html"
OUT_EVIDENCE="PHASE88_14_LIVE_DASHBOARD_ATTACHMENT_EVIDENCE.txt"
OUT_BOOT_LOG="PHASE88_14_SERVER_BOOT.log"
PID_FILE=".phase88_14_server.pid"

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

if ! wait_for_url "$DASHBOARD_URL" 1 1; then
  nohup node server.mjs > "$OUT_BOOT_LOG" 2>&1 &
  echo $! > "$PID_FILE"
fi

wait_for_url "$DASHBOARD_URL" 30 1

curl -fsS "$SYSTEM_HEALTH_URL" > "$OUT_JSON"
curl -fsS "$DASHBOARD_URL" > "$OUT_HTML"

python3 - << 'PY'
import json
from pathlib import Path

system_health = json.loads(Path("PHASE88_14_LIVE_SYSTEM_HEALTH_RESPONSE.json").read_text())
html = Path("PHASE88_14_LIVE_DASHBOARD.html").read_text()

assert system_health["status"] == "OK", "Expected status OK"
assert "situationSummary" in system_health, "Expected situationSummary in system health response"
assert "SYSTEM STABLE" in system_health["situationSummary"], "Expected stable summary line"
assert 'id="system-health-content"' in html, "Expected system-health-content panel in dashboard HTML"
assert "System Health Diagnostics" in html, "Expected System Health Diagnostics card in dashboard HTML"
assert "/diagnostics/system-health" in html, "Expected dashboard health endpoint wiring"
assert "SITUATION SUMMARY" in html, "Expected situation summary rendering label in dashboard HTML"
PY

{
  echo "PHASE 88.14 LIVE DASHBOARD ATTACHMENT EVIDENCE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "Base URL: $BASE_URL"
  echo "────────────────────────────────"
  if [[ -f "$PID_FILE" ]]; then
    echo "Started local server PID: $(cat "$PID_FILE")"
    echo "Boot Log File: $OUT_BOOT_LOG"
    echo "────────────────────────────────"
  fi
  echo "SYSTEM HEALTH RESPONSE:"
  cat "$OUT_JSON"
  echo
  echo "────────────────────────────────"
  echo "DASHBOARD HTML HITS:"
  rg -n 'system-health-content|System Health Diagnostics|SITUATION SUMMARY|/diagnostics/system-health' "$OUT_HTML"
  echo "────────────────────────────────"
  echo "RESULT: PASS"
} | tee "$OUT_EVIDENCE"
