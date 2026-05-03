#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

LATEST_TOP="$(ls -t docs/phase487_top_boundary_candidate_*.txt 2>/dev/null | head -n 1 || true)"
if [ -z "${LATEST_TOP}" ]; then
  echo "No phase487 top boundary candidate file found in docs/"
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
OUT="docs/phase487_exact_line_numbers_${STAMP}.txt"

{
  echo "PHASE 487 — EXACT LINE NUMBERS"
  echo "timestamp=${STAMP}"
  echo "selected_source=${TOP_FILE}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== GUIDANCE MATCHES ==="
  rg -n "Operator Guidance|guidance" "${TOP_FILE}" || true
  echo

  echo "=== INSUFFICIENT MATCHES ==="
  rg -n "insufficient" "${TOP_FILE}" || true
  echo

  echo "=== STATUS / REASON MATCHES ==="
  rg -n "status|reason" "${TOP_FILE}" || true
  echo

  echo "=== FALLBACK / DEFAULT / STATE MATCHES ==="
  rg -n "fallback|default|useState|initialState" "${TOP_FILE}" || true
  echo

  echo "=== HYDRATION / EMPTY-STATE MATCHES ==="
  rg -n "loading|pending|hydrate|hydration|undefined|null" "${TOP_FILE}" || true
  echo

  echo "=== COMBINED HIGH-SIGNAL WINDOWS ==="
  for line in $(rg -n "Operator Guidance|guidance|insufficient|status|reason|fallback|default|useState|initialState|loading|pending|hydrate|hydration|undefined|null" "${TOP_FILE}" | cut -d: -f1 | sort -n | uniq); do
    start=$(( line > 8 ? line - 8 : 1 ))
    end=$(( line + 8 ))
    echo "----- ${TOP_FILE}:${start}-${end} -----"
    sed -n "${start},${end}p" "${TOP_FILE}" || true
    echo
  done
} > "${OUT}"

echo "${OUT}"
