#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://127.0.0.1:3000}"
SYSTEM_HEALTH_URL="$BASE_URL/diagnostics/system-health"

CANDIDATE_URLS=(
  "$BASE_URL/public/dashboard.html"
  "$BASE_URL/"
  "$BASE_URL/dashboard"
)

OUT_JSON="PHASE88_14_2_PUBLIC_DASHBOARD_SYSTEM_HEALTH_RESPONSE.json"
OUT_HTML="PHASE88_14_2_PUBLIC_DASHBOARD.html"
OUT_EVIDENCE="PHASE88_14_2_PUBLIC_DASHBOARD_ATTACHMENT_EVIDENCE.txt"
OUT_HEADERS="PHASE88_14_2_PUBLIC_DASHBOARD_HEADERS.txt"

fetch_first_working_dashboard() {
  : > "$OUT_HEADERS"

  for url in "${CANDIDATE_URLS[@]}"; do
    local tmp_headers
    local tmp_body
    tmp_headers="$(mktemp)"
    tmp_body="$(mktemp)"

    if curl -sS -D "$tmp_headers" -o "$tmp_body" "$url"; then
      local status
      status="$(awk 'NR==1 {print $2}' "$tmp_headers")"

      if [[ "$status" == "200" ]] && grep -q 'Operator Console' "$tmp_body"; then
        mv "$tmp_headers" "$OUT_HEADERS"
        mv "$tmp_body" "$OUT_HTML"
        echo "$url"
        return 0
      fi
    fi

    rm -f "$tmp_headers" "$tmp_body"
  done

  return 1
}

curl -fsS "$SYSTEM_HEALTH_URL" > "$OUT_JSON"
WORKING_DASHBOARD_URL="$(fetch_first_working_dashboard)"

python3 - << 'PY'
import json
from pathlib import Path

system_health = json.loads(Path("PHASE88_14_2_PUBLIC_DASHBOARD_SYSTEM_HEALTH_RESPONSE.json").read_text())
html = Path("PHASE88_14_2_PUBLIC_DASHBOARD.html").read_text()

assert system_health["status"] == "OK", "Expected status OK"
assert "situationSummary" in system_health, "Expected situationSummary in system health response"
assert "SYSTEM STABLE" in system_health["situationSummary"], "Expected stable summary line"
assert 'id="system-health-content"' in html, "Expected system-health-content panel in dashboard HTML"
assert "System Health Diagnostics" in html, "Expected System Health Diagnostics card in dashboard HTML"
assert "/diagnostics/system-health" in html, "Expected dashboard health endpoint wiring"
assert "SITUATION SUMMARY" in html, "Expected situation summary rendering label in dashboard HTML"
PY

{
  echo "PHASE 88.14.2 PUBLIC DASHBOARD ATTACHMENT EVIDENCE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "Base URL: $BASE_URL"
  echo "Dashboard URL: $WORKING_DASHBOARD_URL"
  echo "────────────────────────────────"
  echo "SYSTEM HEALTH RESPONSE:"
  cat "$OUT_JSON"
  echo
  echo "────────────────────────────────"
  echo "DASHBOARD HEADERS:"
  cat "$OUT_HEADERS"
  echo "────────────────────────────────"
  echo "PUBLIC DASHBOARD HTML HITS:"
  rg -n 'system-health-content|System Health Diagnostics|SITUATION SUMMARY|/diagnostics/system-health' "$OUT_HTML"
  echo "────────────────────────────────"
  echo "RESULT: PASS"
} | tee "$OUT_EVIDENCE"
