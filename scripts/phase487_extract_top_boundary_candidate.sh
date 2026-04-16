#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

LATEST="$(ls -t docs/phase487_exact_boundary_candidates_*.txt 2>/dev/null | head -n 1 || true)"
if [ -z "${LATEST}" ]; then
  echo "No phase487 exact boundary candidate file found in docs/"
  exit 1
fi

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_top_boundary_candidate_${STAMP}.txt"

{
  echo "PHASE 487 — TOP BOUNDARY CANDIDATE EXTRACTION"
  echo "timestamp=${STAMP}"
  echo "source_file=${LATEST}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== TOP FILES WITH HIGHEST SIGNAL DENSITY ==="
  awk '/=== FILES WITH HIGHEST SIGNAL DENSITY ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST}" | sed '/^[[:space:]]*$/d'
  echo

  TOP_FILE="$(awk '
    /=== FILES WITH HIGHEST SIGNAL DENSITY ===/ {flag=1; next}
    /^=== / {if(flag) exit}
    flag && NF >= 2 {print $2; exit}
  ' "${LATEST}")"

  echo "=== SELECTED TOP FILE ==="
  echo "${TOP_FILE:-NONE}"
  echo

  if [ -n "${TOP_FILE:-}" ] && [ -f "${TOP_FILE}" ]; then
    echo "=== CONTEXT: insufficient ==="
    rg -n -C 6 "insufficient" "${TOP_FILE}" || true
    echo

    echo "=== CONTEXT: guidance ==="
    rg -n -C 6 "Operator Guidance|guidance" "${TOP_FILE}" || true
    echo

    echo "=== CONTEXT: status|reason ==="
    rg -n -C 6 "status|reason" "${TOP_FILE}" || true
    echo

    echo "=== CONTEXT: fallback|default|useState|initialState ==="
    rg -n -C 6 "fallback|default|useState|initialState" "${TOP_FILE}" || true
    echo

    echo "=== CONTEXT: loading|pending|hydrate|hydration|undefined|null ==="
    rg -n -C 6 "loading|pending|hydrate|hydration|undefined|null" "${TOP_FILE}" || true
    echo
  else
    echo "Top file missing or not found in repo."
    echo
  fi

  echo "=== DECISION TARGET ==="
  echo "Confirm whether the selected top file contains:"
  echo "1. guidance render/output"
  echo "2. status/reason read"
  echo "3. fallback/default/undefined path"
  echo
  echo "If yes, this is the exact UI failure boundary for the incorrect insufficient render."
} > "${OUT}"

echo "${OUT}"
