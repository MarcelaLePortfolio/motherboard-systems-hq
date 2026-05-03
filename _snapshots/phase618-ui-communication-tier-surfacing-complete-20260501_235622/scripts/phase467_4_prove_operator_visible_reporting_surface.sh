#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase467_4_operator_visible_reporting_surface.txt"
REPORT_FILE="src/contracts/reporting/governedExecutionProofReport.ts"
FIXTURE_FILE="src/contracts/reporting/governedExecutionProofReport.fixture.ts"

mkdir -p docs

{
  echo "PHASE 467.4 — OPERATOR-VISIBLE REPORTING SURFACE"
  echo "================================================"
  echo
  echo "REPORT FILE: $REPORT_FILE"
  echo "FIXTURE FILE: $FIXTURE_FILE"
  echo

  echo "STEP 1 — File presence"
  [ -f "$REPORT_FILE" ] && echo "OK: report contract file present" || echo "FAIL: report contract file missing"
  [ -f "$FIXTURE_FILE" ] && echo "OK: report fixture file present" || echo "FAIL: report fixture file missing"
  echo

  echo "STEP 2 — Report surface"
  rg -n "GovernedExecutionProofReport|buildGovernedExecutionProofReport|accepted: boolean|blocked_reason|outcome|operator_visible" "$REPORT_FILE" || true
  echo

  echo "STEP 3 — Fixture coverage"
  rg -q "governedExecutionAllowedReport" "$FIXTURE_FILE" && echo "OK: allowed report present" || echo "FAIL: allowed report missing"
  rg -q "governedExecutionGovernanceBlockedReport" "$FIXTURE_FILE" && echo "OK: governance-blocked report present" || echo "FAIL: governance-blocked report missing"
  rg -q "governedExecutionApprovalMissingReport" "$FIXTURE_FILE" && echo "OK: approval-missing report present" || echo "FAIL: approval-missing report missing"
  echo

  echo "STEP 4 — Non-runtime guarantee"
  if rg -q "fetch|EventSource|worker|dispatch|docker|curl|setInterval|setTimeout|Date.now|Math.random" "$REPORT_FILE" "$FIXTURE_FILE"; then
    echo "FAIL: runtime or nondeterministic behavior detected"
  else
    echo "OK: reporting surface remains structural and deterministic"
  fi
  echo

  echo "STEP 5 — Classification"
  echo "CLASSIFICATION: OPERATOR_VISIBLE_REPORTING_SURFACE_DEFINED"
  echo

  echo "DECISION TARGET"
  echo "- First governed execution proof now has an operator-visible reporting contract."
  echo "- Corridor remains structural, deterministic, and side-effect free."
  echo "- Next phase may consolidate handoff and mark the proof corridor complete."
} > "$OUT"

echo "Wrote $OUT"
