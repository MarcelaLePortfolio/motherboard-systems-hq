#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://127.0.0.1:3000}"

HEALTH_CANDIDATES=(
  "$BASE_URL/diagnostics/system-health"
  "$BASE_URL/diagnostics/systemHealth"
  "$BASE_URL/system-health"
  "$BASE_URL/health"
)

DASHBOARD_CANDIDATES=(
  "$BASE_URL/dashboard"
  "$BASE_URL/public/dashboard.html"
  "$BASE_URL/"
)

OUT_EVIDENCE="PHASE88_14_3_LIVE_HEALTH_AND_DASHBOARD_CANDIDATES.txt"

probe_url() {
  local url="$1"
  local header_file
  local body_file
  header_file="$(mktemp)"
  body_file="$(mktemp)"

  curl -sS -D "$header_file" -o "$body_file" "$url" || true

  local status
  status="$(awk 'NR==1 {print $2}' "$header_file")"

  echo "URL: $url"
  echo "STATUS: ${status:-UNKNOWN}"

  if grep -q '"status"' "$body_file" 2>/dev/null; then
    echo "BODY TYPE: json-like"
    sed -n '1,80p' "$body_file"
  else
    echo "BODY TYPE: html-or-text"
    sed -n '1,40p' "$body_file"
  fi

  echo "────────────────────────────────"

  rm -f "$header_file" "$body_file"
}

{
  echo "PHASE 88.14.3 LIVE HEALTH AND DASHBOARD CANDIDATES"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "Base URL: $BASE_URL"
  echo "────────────────────────────────"
  echo "SECTION: HEALTH CANDIDATES"
  for url in "${HEALTH_CANDIDATES[@]}"; do
    probe_url "$url"
  done
  echo "SECTION: DASHBOARD CANDIDATES"
  for url in "${DASHBOARD_CANDIDATES[@]}"; do
    probe_url "$url"
  done
} | tee "$OUT_EVIDENCE"
