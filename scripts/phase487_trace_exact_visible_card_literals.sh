#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_trace_exact_visible_card_literals_${STAMP}.txt"
TMP_FILES="$(mktemp)"

find dashboard/src app src ui . \
  \( -path "./.git" -o -path "./node_modules" -o -path "./.next" -o -path "./dist" -o -path "./coverage" \) -prune -o \
  \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \) -print 2>/dev/null | sort -u > "${TMP_FILES}"

{
  echo "PHASE 487 — TRACE EXACT VISIBLE CARD LITERALS"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== EXACT VISIBLE STRINGS ==="
  xargs rg -n -C 8 "Awaiting bounded guidance stream|Live operator guidance will appear here when visibility wiring is active|Confidence: insufficient|Confidence:|Sources: diagnostics/system-health" < "${TMP_FILES}" 2>/dev/null || true
  echo

  echo "=== CONFIDENCE FORMATTERS ==="
  xargs rg -n -C 8 "surfaceConfidence|confidenceLabel|confidence[^A-Za-z]|insufficient|limited" < "${TMP_FILES}" 2>/dev/null || true
  echo

  echo "=== DASHBOARD-ONLY CANDIDATES ==="
  xargs rg -l "Awaiting bounded guidance stream|Live operator guidance will appear here when visibility wiring is active|Confidence:|Sources:" < "${TMP_FILES}" 2>/dev/null | sort -u || true
  echo

  echo "=== NEXT PATCH TARGET ==="
  echo "Patch the file that contains the exact visible strings above."
  echo "Do not patch mapping layers again."
  echo
} > "${OUT}"

rm -f "${TMP_FILES}"

echo "${OUT}"
