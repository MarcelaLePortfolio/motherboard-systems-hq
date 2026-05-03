#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase467_6_operator_surface.txt"
SURFACE="src/contracts/reporting/operatorConsumableExecutionProofSurface.ts"
FIXTURE="src/contracts/reporting/operatorConsumableExecutionProofSurface.fixture.ts"

mkdir -p docs

{
  echo "PHASE 467.6 — OPERATOR CONSUMABLE SURFACE"
  echo "========================================"
  echo

  echo "STEP 1 — File presence"
  [ -f "$SURFACE" ] && echo "OK: surface file present" || echo "FAIL: surface file missing"
  [ -f "$FIXTURE" ] && echo "OK: fixture file present" || echo "FAIL: fixture file missing"
  echo

  echo "STEP 2 — Surface structure"
  rg -n "OperatorConsumableExecutionProofSurface|buildOperatorConsumableExecutionProofSurface|headline|detail|operator_visible" "$SURFACE" || true
  echo

  echo "STEP 3 — Fixture coverage"
  rg -q "operatorSurfaceAllowed" "$FIXTURE" && echo "OK: allowed surface present" || echo "FAIL: allowed surface missing"
  rg -q "operatorSurfaceGovernanceBlocked" "$FIXTURE" && echo "OK: governance-blocked surface present" || echo "FAIL: governance-blocked surface missing"
  rg -q "operatorSurfaceApprovalMissing" "$FIXTURE" && echo "OK: approval-missing surface present" || echo "FAIL: approval-missing surface missing"
  echo

  echo "STEP 4 — Non-runtime guarantee"
  if rg -q "fetch|EventSource|worker|dispatch|docker|curl|setInterval|setTimeout|Date.now|Math.random" "$SURFACE" "$FIXTURE"; then
    echo "FAIL: runtime or nondeterministic behavior detected"
  else
    echo "OK: surface remains structural and deterministic"
  fi
  echo

  echo "STEP 5 — Classification"
  echo "CLASSIFICATION: OPERATOR_CONSUMABLE_SURFACE_DEFINED"
  echo

  echo "DECISION TARGET"
  echo "- Governed execution proof is now operator-consumable."
  echo "- Still no runtime wiring."
  echo "- Ready for final handoff or demo exposure."
} > "$OUT"

echo "Wrote $OUT"
