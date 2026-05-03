#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

LATEST="$(ls -t docs/phase487_exact_visible_confidence_context_*.txt 2>/dev/null | head -n 1 || true)"
if [ -z "${LATEST}" ]; then
  echo "No exact visible confidence context doc found."
  exit 1
fi

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_visible_confidence_render_expression_${STAMP}.txt"

{
  echo "PHASE 487 — VISIBLE CONFIDENCE RENDER EXPRESSION"
  echo "timestamp=${STAMP}"
  echo "source_file=${LATEST}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== TARGET FILE ==="
  awk -F= '/^target_file=/{print $2}' "${LATEST}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
  echo

  echo "=== HIGH-SIGNAL LINES FROM CONTEXT DOC ==="
  grep -nE "Confidence:|confidence|insufficient|limited|Awaiting bounded guidance stream|Live operator guidance will appear here when visibility wiring is active|diagnostics/system-health" "${LATEST}" | head -n 200 || true
  echo

  echo "=== LIKELY RENDER WINDOWS ==="
  awk '
    /=== ALL CONFIDENCE MATCHES IN TARGET FILE ===/ {flag=1; next}
    /=== FIRST 320 LINES ===/ {if(flag) exit}
    flag {print}
  ' "${LATEST}" | sed '/^[[:space:]]*$/d' | head -n 240 || true
  echo

  echo "=== GLOBAL STRING TRACE WINDOWS ==="
  awk '
    /=== GLOBAL EXACT STRING TRACE ===/ {flag=1; next}
    /=== NEXT READ ===/ {if(flag) exit}
    flag {print}
  ' "${LATEST}" | sed '/^[[:space:]]*$/d' | head -n 240 || true
  echo

  echo "=== DECISION TARGET ==="
  echo "Identify the exact expression that renders the visible confidence value."
  echo "Next patch must touch only that render expression."
  echo
} > "${OUT}"

echo "${OUT}"
