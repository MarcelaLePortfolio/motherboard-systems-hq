#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_operator_guidance_card_literals_${STAMP}.txt"
TMP_FILES="$(mktemp)"

find . \
  \( -path "./.git" -o -path "./node_modules" -o -path "./.next" -o -path "./dist" -o -path "./coverage" \) -prune -o \
  \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \) -print | sort -u > "${TMP_FILES}"

{
  echo "PHASE 487 — OPERATOR GUIDANCE CARD LITERAL TRACE"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== SEARCH: exact card literals ==="
  xargs rg -n -C 3 "Awaiting bounded guidance stream|Live operator guidance will appear here when visibility wiring is active|Sources:|Confidence:" < "${TMP_FILES}" 2>/dev/null || true
  echo

  echo "=== SEARCH: remaining insufficient render paths ==="
  xargs rg -n -C 3 "Confidence: insufficient|confidence.*insufficient|insufficient" < "${TMP_FILES}" 2>/dev/null || true
  echo

  echo "=== SEARCH: patched guidance sources ==="
  xargs rg -n -C 3 "operatorGuidanceConfidence|operatorGuidanceMapping|limited; interpret with caution|awaiting stronger signal|limited" < "${TMP_FILES}" 2>/dev/null || true
  echo

  echo "=== DECISION TARGET ==="
  echo "Find the exact display component containing the visible card literals."
  echo "That component is the next surgical patch site."
  echo
} > "${OUT}"

rm -f "${TMP_FILES}"

echo "${OUT}"
