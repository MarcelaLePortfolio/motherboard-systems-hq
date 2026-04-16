#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

LATEST="$(ls -t docs/phase487_top_boundary_candidate_*.txt 2>/dev/null | head -n 1 || true)"
if [ -z "${LATEST}" ]; then
  echo "No phase487 top boundary candidate file found in docs/"
  exit 1
fi

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_boundary_verdict_${STAMP}.txt"

TOP_FILE="$(awk '
  /=== SELECTED TOP FILE ===/ {getline; gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0); print; exit}
' "${LATEST}")"

HAS_GUIDANCE="NO"
HAS_STATUS_REASON="NO"
HAS_FALLBACK="NO"

grep -Eq "=== CONTEXT: guidance ===" "${LATEST}" && \
  awk '/=== CONTEXT: guidance ===/{flag=1;next}/^=== /{if(flag) exit}flag' "${LATEST}" | grep -q . && HAS_GUIDANCE="YES" || true

grep -Eq "=== CONTEXT: status\|reason ===" "${LATEST}" && \
  awk '/=== CONTEXT: status\|reason ===/{flag=1;next}/^=== /{if(flag) exit}flag' "${LATEST}" | grep -q . && HAS_STATUS_REASON="YES" || true

grep -Eq "=== CONTEXT: fallback\|default\|useState\|initialState ===" "${LATEST}" && \
  awk '/=== CONTEXT: fallback\|default\|useState\|initialState ===/{flag=1;next}/^=== /{if(flag) exit}flag' "${LATEST}" | grep -q . && HAS_FALLBACK="YES" || true

{
  echo "PHASE 487 — BOUNDARY VERDICT"
  echo "timestamp=${STAMP}"
  echo "source_file=${LATEST}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== SELECTED TOP FILE ==="
  echo "${TOP_FILE:-NONE}"
  echo

  echo "=== SIGNAL CHECK ==="
  echo "guidance_render=${HAS_GUIDANCE}"
  echo "status_reason_read=${HAS_STATUS_REASON}"
  echo "fallback_default_path=${HAS_FALLBACK}"
  echo

  echo "=== VERDICT ==="
  if [ -n "${TOP_FILE:-}" ] && [ "${HAS_GUIDANCE}" = "YES" ] && [ "${HAS_STATUS_REASON}" = "YES" ] && [ "${HAS_FALLBACK}" = "YES" ]; then
    echo "Exact boundary candidate confirmed at:"
    echo "${TOP_FILE}"
    echo
    echo "Failure class:"
    echo "UI-side interpretation boundary"
    echo
    echo "Most likely mechanism:"
    echo "Fallback/default/undefined path is collapsing valid or not-yet-hydrated guidance into an incorrect insufficient render."
  else
    echo "Exact boundary not yet fully confirmed."
    echo
    echo "Current best candidate:"
    echo "${TOP_FILE:-NONE}"
    echo
    echo "Missing signal(s) indicate one more direct source inspection step may be required."
  fi
  echo

  echo "=== NEXT ENGINEERING ACTION ==="
  echo "Prepare a surgical UI-only patch at the confirmed boundary:"
  echo "1. preserve existing contracts"
  echo "2. remove incorrect insufficient fallback behavior"
  echo "3. do not mutate backend/governance/execution"
  echo
} > "${OUT}"

echo "${OUT}"
