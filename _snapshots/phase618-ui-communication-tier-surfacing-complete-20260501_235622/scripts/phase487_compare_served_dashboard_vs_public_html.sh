#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_compare_served_dashboard_vs_public_html_${STAMP}.txt"
SERVED_HTML="docs/phase487_served_dashboard_snapshot_${STAMP}.html"

curl -s http://localhost:8080 > "${SERVED_HTML}"

{
  echo "PHASE 487 — COMPARE SERVED DASHBOARD VS PUBLIC HTML"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== SERVED BODY STRING CHECK ==="
  rg -n -C 3 "Awaiting bounded guidance stream|Live operator guidance will appear here when visibility wiring is active|Confidence: insufficient|Confidence: limited|Sources: diagnostics/system-health" "${SERVED_HTML}" || true
  echo

  echo "=== LOCAL public/dashboard.html STRING CHECK ==="
  rg -n -C 3 "Awaiting bounded guidance stream|Live operator guidance will appear here when visibility wiring is active|Confidence: insufficient|Confidence: limited|Sources: diagnostics/system-health" public/dashboard.html 2>/dev/null || true
  echo

  echo "=== HASHES ==="
  shasum "${SERVED_HTML}" 2>/dev/null || true
  shasum public/dashboard.html 2>/dev/null || true
  echo

  echo "=== FILE MTIME ==="
  stat -f "%Sm %N" public/dashboard.html 2>/dev/null || true
  echo

  echo "=== PORT 8080 OWNER ==="
  lsof -nP -iTCP:8080 -sTCP:LISTEN || true
  echo

  echo "=== PM2 STATUS ==="
  pm2 list 2>/dev/null || true
  echo

  echo "=== EXACT STRING LOCATIONS IN REPO ==="
  find . \
    \( -path "./.git" -o -path "./node_modules" -o -path "./coverage" \) -prune -o \
    \( -type f \( -name "*.html" -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \) \) -print0 \
    | xargs -0 rg -n -C 2 "Confidence: insufficient|Awaiting bounded guidance stream|Live operator guidance will appear here when visibility wiring is active|Sources: diagnostics/system-health" 2>/dev/null || true
  echo

  echo "=== NEXT READ ==="
  echo "If served HTML still contains Confidence: insufficient while public/dashboard.html does not,"
  echo "the active server is serving a different artifact than public/dashboard.html."
  echo
} > "${OUT}"

echo "${OUT}"
echo "${SERVED_HTML}"
