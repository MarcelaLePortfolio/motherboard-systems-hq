#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_guidance_trace_probe_${STAMP}.txt"

SEARCH_DIRS=()
for dir in app src components ui lib pages; do
  if [ -d "$dir" ]; then
    SEARCH_DIRS+=("$dir")
  fi
done

if [ "${#SEARCH_DIRS[@]}" -eq 0 ]; then
  SEARCH_DIRS=(.)
fi

{
  echo "PHASE 487 — GUIDANCE TRACE PROBE"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo "search_dirs=${SEARCH_DIRS[*]}"
  echo

  echo "=== STEP 1: FIND GUIDANCE RENDER ENTRY ==="
  rg -n -S "Operator Guidance|guidance" "${SEARCH_DIRS[@]}" \
    --glob '!.git' \
    --glob '!node_modules' \
    --glob '!.next' \
    --glob '!dist' \
    --glob '!coverage' || true
  echo

  echo "=== STEP 2: TRACE STATUS FIELD USAGE ==="
  rg -n -S "status" "${SEARCH_DIRS[@]}" \
    --glob '!.git' \
    --glob '!node_modules' \
    --glob '!.next' \
    --glob '!dist' \
    --glob '!coverage' || true
  echo

  echo "=== STEP 3: TRACE REASON FIELD USAGE ==="
  rg -n -S "reason" "${SEARCH_DIRS[@]}" \
    --glob '!.git' \
    --glob '!node_modules' \
    --glob '!.next' \
    --glob '!dist' \
    --glob '!coverage' || true
  echo

  echo "=== STEP 4: TRACE ANY 'insufficient' ASSIGNMENTS ==="
  rg -n -S "insufficient" "${SEARCH_DIRS[@]}" \
    --glob '!.git' \
    --glob '!node_modules' \
    --glob '!.next' \
    --glob '!dist' \
    --glob '!coverage' || true
  echo

  echo "=== STEP 5: TRACE STATE INITIALIZATION ==="
  rg -n -S "useState|initialState|fallback|default" "${SEARCH_DIRS[@]}" \
    --glob '!.git' \
    --glob '!node_modules' \
    --glob '!.next' \
    --glob '!dist' \
    --glob '!coverage' || true
  echo

  echo "=== STEP 6: TRACE EFFECT / HYDRATION ==="
  rg -n -S "useEffect|loading|pending|hydrate|hydration|undefined|null" "${SEARCH_DIRS[@]}" \
    --glob '!.git' \
    --glob '!node_modules' \
    --glob '!.next' \
    --glob '!dist' \
    --glob '!coverage' || true
  echo

  echo "=== STEP 7: TARGET FILE SHORTLIST ==="
  rg -l -S "guidance|status|reason|insufficient" "${SEARCH_DIRS[@]}" \
    --glob '!.git' \
    --glob '!node_modules' \
    --glob '!.next' \
    --glob '!dist' \
    --glob '!coverage' | sort -u || true
  echo

  echo "=== STEP 8: LIKELY FAILURE BOUNDARIES ==="
  rg -n -S "insufficient|fallback|default|status|reason|guidance" "${SEARCH_DIRS[@]}" \
    --glob '!.git' \
    --glob '!node_modules' \
    --glob '!.next' \
    --glob '!dist' \
    --glob '!coverage' | head -n 200 || true
  echo

  echo "=== INTERPRETATION TARGET ==="
  echo "Identify exact line where:"
  echo "• valid governance output becomes insufficient"
  echo "• OR UI defaults to insufficient before hydration"
  echo
} > "${OUT}"

echo "${OUT}"
