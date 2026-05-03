#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

LATEST_VERDICT="$(ls -t docs/phase487_boundary_verdict_*.txt 2>/dev/null | head -n 1 || true)"
LATEST_TOP="$(ls -t docs/phase487_top_boundary_candidate_*.txt 2>/dev/null | head -n 1 || true)"

if [ -z "${LATEST_VERDICT}" ] || [ -z "${LATEST_TOP}" ]; then
  echo "Required Phase 487 evidence files not found in docs/"
  exit 1
fi

TOP_FILE="$(awk '
  /=== SELECTED TOP FILE ===/ {getline; gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0); print; exit}
' "${LATEST_TOP}")"

if [ -z "${TOP_FILE}" ] || [ ! -f "${TOP_FILE}" ]; then
  echo "Top file missing or not found: ${TOP_FILE:-NONE}"
  exit 1
fi

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_direct_top_file_inspection_${STAMP}.txt"

{
  echo "PHASE 487 — DIRECT TOP FILE INSPECTION"
  echo "timestamp=${STAMP}"
  echo "verdict_file=${LATEST_VERDICT}"
  echo "top_candidate_file=${LATEST_TOP}"
  echo "selected_source=${TOP_FILE}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== FULL FILE HEADER ==="
  sed -n '1,220p' "${TOP_FILE}" || true
  echo

  echo "=== MATCH: insufficient ==="
  rg -n -C 12 "insufficient" "${TOP_FILE}" || true
  echo

  echo "=== MATCH: guidance ==="
  rg -n -C 12 "Operator Guidance|guidance" "${TOP_FILE}" || true
  echo

  echo "=== MATCH: status|reason ==="
  rg -n -C 12 "status|reason" "${TOP_FILE}" || true
  echo

  echo "=== MATCH: fallback|default|useState|initialState ==="
  rg -n -C 12 "fallback|default|useState|initialState" "${TOP_FILE}" || true
  echo

  echo "=== MATCH: loading|pending|hydrate|hydration|undefined|null ==="
  rg -n -C 12 "loading|pending|hydrate|hydration|undefined|null" "${TOP_FILE}" || true
  echo

  echo "=== FULL FILE TAIL ==="
  tail -n 220 "${TOP_FILE}" || true
  echo

  echo "=== DECISION TARGET ==="
  echo "Manually confirm the exact line where:"
  echo "1. displayed guidance label is computed"
  echo "2. status/reason is read from payload/state"
  echo "3. fallback/default/undefined branch can emit insufficient"
  echo
  echo "This output is the final pre-patch inspection artifact."
} > "${OUT}"

echo "${OUT}"
