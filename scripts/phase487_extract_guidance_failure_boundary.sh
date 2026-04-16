#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

LATEST="$(ls -t docs/phase487_guidance_trace_probe_*.txt 2>/dev/null | head -n 1 || true)"
if [ -z "${LATEST}" ]; then
  echo "No phase487 guidance trace probe file found in docs/"
  exit 1
fi

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_guidance_failure_boundary_${STAMP}.txt"

{
  echo "PHASE 487 — GUIDANCE FAILURE BOUNDARY EXTRACTION"
  echo "timestamp=${STAMP}"
  echo "source_trace=${LATEST}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== SECTION 1: FILE SHORTLIST ==="
  awk '/=== STEP 7: TARGET FILE SHORTLIST ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST}" || true
  echo

  echo "=== SECTION 2: INSUFFICIENT LINES ==="
  grep -n -i "insufficient" "${LATEST}" || true
  echo

  echo "=== SECTION 3: STATUS LINES ==="
  grep -n -i "status" "${LATEST}" || true
  echo

  echo "=== SECTION 4: REASON LINES ==="
  grep -n -i "reason" "${LATEST}" || true
  echo

  echo "=== SECTION 5: STATE / FALLBACK / DEFAULT LINES ==="
  grep -n -E "useState|initialState|fallback|default|loading|pending|hydrate|hydration|undefined|null" "${LATEST}" || true
  echo

  echo "=== SECTION 6: LIKELY FAILURE BOUNDARY CANDIDATES (FIRST 120 HIGH-SIGNAL LINES) ==="
  grep -n -E "insufficient|status|reason|guidance|useState|initialState|fallback|default|loading|pending|hydrate|hydration|undefined|null" "${LATEST}" | head -n 120 || true
  echo

  echo "=== SECTION 7: INTERPRETATION FRAME ==="
  echo "Candidate classes:"
  echo "A. UI default/fallback assigns insufficient before payload hydration"
  echo "B. UI expects status/reason fields that are absent or renamed"
  echo "C. Mapping layer collapses undefined/null into insufficient"
  echo "D. Render entry consumes stale placeholder state"
  echo
  echo "NEXT MANUAL READ TARGET:"
  echo "Open the specific source files listed in SECTION 1 and inspect the lines referenced above."
  echo
} > "${OUT}"

echo "${OUT}"
