#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_guidance_trace_probe_${STAMP}.txt"

{
  echo "PHASE 487 — GUIDANCE TRACE PROBE"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== STEP 1: FIND GUIDANCE RENDER ENTRY ==="
  rg -n "Operator Guidance" app src components || true
  echo

  echo "=== STEP 2: TRACE STATUS FIELD USAGE ==="
  rg -n "status" app src components || true
  echo

  echo "=== STEP 3: TRACE REASON FIELD USAGE ==="
  rg -n "reason" app src components || true
  echo

  echo "=== STEP 4: TRACE ANY 'insufficient' ASSIGNMENTS ==="
  rg -n "insufficient" app src components || true
  echo

  echo "=== STEP 5: TRACE STATE INITIALIZATION ==="
  rg -n "useState" app src components || true
  echo

  echo "=== STEP 6: TRACE EFFECT / HYDRATION ==="
  rg -n "useEffect" app src components || true
  echo

  echo "=== STEP 7: TARGET FILE SHORTLIST ==="
  rg -l "guidance|status|reason|insufficient" app src components | sort | uniq || true
  echo

  echo "=== INTERPRETATION TARGET ==="
  echo "Identify exact line where:"
  echo "• valid governance output becomes 'insufficient'"
  echo "• OR UI defaults to insufficient before hydration"
  echo
} > "${OUT}"

echo "${OUT}"
