#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

INPUT="docs/recovery_full_audit/13_phase61_to_fl3_corridor_scan.txt"
OUT="docs/recovery_full_audit/14_recovery_candidate_shortlist.txt"

mkdir -p docs/recovery_full_audit

{
  echo "PHASE 457 - RECOVERY CANDIDATE SHORTLIST"
  echo "========================================"
  echo
  echo "PURPOSE"
  echo "Extract the most relevant dashboard/layout/wiring commits from the Phase61-to-FL3 corridor scan."
  echo
  echo "INTERPRETATION RULE"
  echo "Prefer commits that preserve the Phase 61/62/63/64/65 dashboard structure and later wiring,"
  echo "without jumping straight into unrelated downstream UI mutations."
  echo
  echo "=== HIGH-SIGNAL DASHBOARD / LAYOUT / WIRING COMMITS ==="
  grep -E 'Phase 61|Phase 62|Phase 63|Phase 64|Phase 65|restore dashboard|restore stable dashboard|restore interactive dashboard|wire|hydrate|telemetry|recent history|agent pool|task events|delegation|operator guidance' "$INPUT" || true
  echo
  echo "=== HIGH-SIGNAL FL-3 / COGNITION COMMITS ==="
  grep -E '423\.|FL-3|governance|execution entrypoint|cognition|live registry|authorization gate|operator guidance' "$INPUT" || true
  echo
  echo "=== KNOWN ANCHORS ==="
  echo "Layout restore anchor: ee8ea4f8"
  echo "Current branch: phase119-dashboard-cognition-contract"
  echo
  echo "NEXT STEP"
  echo "Review this shortlist and choose the exact recovery checkpoint nearest the desired dashboard state."
} > "$OUT"

echo "WROTE=$OUT"
sed -n '1,260p' "$OUT"
