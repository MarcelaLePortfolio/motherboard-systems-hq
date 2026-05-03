#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

LATEST_REVEAL_DOC="$(ls -t docs/phase487_reveal_exact_operator_guidance_card_target_*.txt 2>/dev/null | head -n 1 || true)"
if [ -z "${LATEST_REVEAL_DOC}" ]; then
  echo "No reveal doc found."
  exit 1
fi

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_exact_visible_confidence_context_${STAMP}.txt"

TARGET_FILE="$(awk -F= '
  /^target_file=/ {
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)
    print $2
    exit
  }
' "${LATEST_REVEAL_DOC}")"

{
  echo "PHASE 487 — EXACT VISIBLE CONFIDENCE CONTEXT"
  echo "timestamp=${STAMP}"
  echo "reveal_doc=${LATEST_REVEAL_DOC}"
  echo "target_file=${TARGET_FILE:-NONE}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  if [ -n "${TARGET_FILE:-}" ] && [ "${TARGET_FILE}" != "NONE" ] && [ -f "${TARGET_FILE}" ]; then
    echo "=== TARGET FILE ==="
    echo "${TARGET_FILE}"
    echo

    echo "=== TARGET FILE FULL PATH CHECK ==="
    ls -l "${TARGET_FILE}" || true
    echo

    echo "=== ALL CONFIDENCE MATCHES IN TARGET FILE ==="
    rg -n -C 12 "Confidence:|confidence|insufficient|limited|diagnostics/system-health|Awaiting bounded guidance stream|Live operator guidance will appear here when visibility wiring is active" "${TARGET_FILE}" || true
    echo

    echo "=== FIRST 320 LINES ==="
    sed -n '1,320p' "${TARGET_FILE}" || true
    echo

    echo "=== LAST 320 LINES ==="
    tail -n 320 "${TARGET_FILE}" || true
    echo
  else
    echo "Target file missing or invalid."
    echo
  fi

  echo "=== GLOBAL EXACT STRING TRACE ==="
  find . \
    \( -path "./.git" -o -path "./node_modules" -o -path "./.next" -o -path "./dist" -o -path "./coverage" \) -prune -o \
    \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.json" \) -print0 \
    | xargs -0 rg -n -C 6 "Awaiting bounded guidance stream|Live operator guidance will appear here when visibility wiring is active|Confidence: insufficient|Confidence: limited|diagnostics/system-health" 2>/dev/null || true
  echo

  echo "=== NEXT READ ==="
  echo "Use this artifact to identify the exact render expression producing the visible confidence value."
  echo
} > "${OUT}"

echo "${OUT}"
