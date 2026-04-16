#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_resolve_display_layer_target_none_${STAMP}.txt"
TMP_FILES="$(mktemp)"

find dashboard/src app src ui . \
  \( -path "./.git" -o -path "./node_modules" -o -path "./.next" -o -path "./dist" -o -path "./coverage" \) -prune -o \
  \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \) -print 2>/dev/null | sort -u > "${TMP_FILES}"

{
  echo "PHASE 487 — RESOLVE DISPLAY-LAYER TARGET NONE"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== EXACT CARD STRING HITS ==="
  xargs rg -n -C 8 "Awaiting bounded guidance stream|Live operator guidance will appear here when visibility wiring is active|Confidence: insufficient|Confidence:|Sources: diagnostics/system-health" < "${TMP_FILES}" 2>/dev/null || true
  echo

  echo "=== DASHBOARD / UI CANDIDATE FILES ==="
  xargs rg -l "Awaiting bounded guidance stream|Live operator guidance will appear here when visibility wiring is active|Confidence:|Sources:" < "${TMP_FILES}" 2>/dev/null | sort -u || true
  echo

  echo "=== CANDIDATE SOURCE WINDOWS ==="
  while IFS= read -r file; do
    [ -n "${file}" ] || continue
    [ -f "${file}" ] || continue
    echo "----- FILE: ${file} -----"
    rg -n -C 10 "Awaiting bounded guidance stream|Live operator guidance will appear here when visibility wiring is active|Confidence:|Sources:|surfaceConfidence|confidenceLabel|insufficient|limited" "${file}" || true
    echo
  done < <(xargs rg -l "Awaiting bounded guidance stream|Live operator guidance will appear here when visibility wiring is active|Confidence:|Sources:" < "${TMP_FILES}" 2>/dev/null | sort -u)
  echo

  echo "=== RECOMMENDED PATCH FILES ==="
  xargs rg -l "Awaiting bounded guidance stream|Live operator guidance will appear here when visibility wiring is active|Confidence:|Sources:" < "${TMP_FILES}" 2>/dev/null | grep -E '^dashboard/src|^app/|^ui/' | sort -u || true
  echo
} > "${OUT}"

rm -f "${TMP_FILES}"

echo "${OUT}"
