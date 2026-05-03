#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

LATEST="$(ls -t docs/phase487_guidance_failure_boundary_*.txt 2>/dev/null | head -n 1 || true)"
if [ -z "${LATEST}" ]; then
  echo "No phase487 guidance failure boundary file found in docs/"
  exit 1
fi

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_failure_boundary_summary_${STAMP}.txt"

{
  echo "PHASE 487 — FAILURE BOUNDARY SUMMARY"
  echo "timestamp=${STAMP}"
  echo "source_file=${LATEST}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== SECTION 1: TARGET FILE SHORTLIST ==="
  awk '/=== SECTION 1: FILE SHORTLIST ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST}" || true
  echo

  echo "=== SECTION 2: TOP 'INSUFFICIENT' MATCHES ==="
  grep -ni "insufficient" "${LATEST}" | head -n 40 || true
  echo

  echo "=== SECTION 3: TOP STATE / FALLBACK MATCHES ==="
  grep -nE "useState|initialState|fallback|default|loading|pending|hydrate|hydration|undefined|null" "${LATEST}" | head -n 60 || true
  echo

  echo "=== SECTION 4: TOP STATUS / REASON MATCHES ==="
  grep -nE "status|reason" "${LATEST}" | head -n 80 || true
  echo

  echo "=== SECTION 5: LIKELY ROOT CAUSE CLASSIFICATION ==="
  echo "Most likely classes to confirm next:"
  echo "1. UI fallback/default assigns insufficient before payload hydration"
  echo "2. UI expects status/reason fields that do not match emitted payload"
  echo "3. Undefined/null mapping collapses into insufficient"
  echo
  echo "NEXT STEP:"
  echo "Open the shortlisted source files and inspect exact lines around:"
  echo "• insufficient"
  echo "• useState / fallback / default"
  echo "• status / reason field reads"
  echo
} > "${OUT}"

echo "${OUT}"
