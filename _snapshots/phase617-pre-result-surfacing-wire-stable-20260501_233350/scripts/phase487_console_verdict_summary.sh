#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

LATEST_LINES="$(ls -t docs/phase487_exact_line_numbers_*.txt 2>/dev/null | head -n 1 || true)"
LATEST_TOP="$(ls -t docs/phase487_top_boundary_candidate_*.txt 2>/dev/null | head -n 1 || true)"
LATEST_VERDICT="$(ls -t docs/phase487_boundary_verdict_*.txt 2>/dev/null | head -n 1 || true)"

if [ -z "${LATEST_LINES}" ] || [ -z "${LATEST_TOP}" ] || [ -z "${LATEST_VERDICT}" ]; then
  echo "Missing Phase 487 evidence files."
  exit 1
fi

TOP_FILE="$(awk '
  /=== SELECTED TOP FILE ===/ {getline; gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0); print; exit}
' "${LATEST_TOP}")"

OUT="docs/phase487_console_verdict_summary_$(date +%Y%m%d_%H%M%S).txt"

{
  echo "PHASE 487 — CONSOLE VERDICT SUMMARY"
  echo "top_file=${TOP_FILE:-NONE}"
  echo "exact_lines_file=${LATEST_LINES}"
  echo "verdict_file=${LATEST_VERDICT}"
  echo

  echo "SUMMARY:"
  echo "• Top candidate file: ${TOP_FILE:-NONE}"
  echo "• Boundary class: UI-side interpretation boundary"
  echo "• Likely mechanism: fallback/default/undefined path collapsing valid or not-yet-hydrated guidance into incorrect insufficient render"
  echo

  echo "TOP MATCHES — GUIDANCE"
  awk '/=== GUIDANCE MATCHES ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST_LINES}" | sed '/^[[:space:]]*$/d' | head -n 12
  echo

  echo "TOP MATCHES — INSUFFICIENT"
  awk '/=== INSUFFICIENT MATCHES ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST_LINES}" | sed '/^[[:space:]]*$/d' | head -n 12
  echo

  echo "TOP MATCHES — STATUS / REASON"
  awk '/=== STATUS \/ REASON MATCHES ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST_LINES}" | sed '/^[[:space:]]*$/d' | head -n 16
  echo

  echo "TOP MATCHES — FALLBACK / DEFAULT / STATE"
  awk '/=== FALLBACK \/ DEFAULT \/ STATE MATCHES ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST_LINES}" | sed '/^[[:space:]]*$/d' | head -n 16
  echo

  echo "NEXT PATCH TARGET:"
  echo "• Patch only ${TOP_FILE:-the selected top file}"
  echo "• Preserve existing contracts"
  echo "• Replace incorrect insufficient fallback with a neutral pre-hydration / unavailable render path"
  echo "• No backend, governance, approval, or execution changes"
  echo
} | tee "${OUT}"
