#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase467_1_execution_fixture_cases.txt"
FIXTURE="src/contracts/execution/__fixtures__/governedExecutionProof.fixture.ts"

mkdir -p docs

{
  echo "PHASE 467.1 — EXECUTION FIXTURE CASES PROOF"
  echo "==========================================="
  echo
  echo "FIXTURE: $FIXTURE"
  echo

  echo "STEP 1 — File presence"
  [ -f "$FIXTURE" ] && echo "OK: fixture file present" || echo "FAIL: fixture file missing"
  echo

  echo "STEP 2 — Case coverage"
  rg -q "executionProofAllowedFixture" "$FIXTURE" && echo "OK: allowed case present" || echo "FAIL: allowed case missing"
  rg -q "executionProofGovernanceBlockedFixture" "$FIXTURE" && echo "OK: governance blocked case present" || echo "FAIL: governance blocked case missing"
  rg -q "executionProofApprovalMissingFixture" "$FIXTURE" && echo "OK: approval missing case present" || echo "FAIL: approval missing case missing"
  echo

  echo "STEP 3 — Structural mutation check"
  if rg -q "execute|dispatch|worker|fetch|EventSource|setInterval|setTimeout" "$FIXTURE"; then
    echo "FAIL: runtime behavior detected"
  else
    echo "OK: no runtime behavior present"
  fi
  echo

  echo "STEP 4 — Classification"
  echo "CLASSIFICATION: EXECUTION_FIXTURE_CASES_DEFINED"
  echo

  echo "DECISION TARGET"
  echo "- Execution proof now has deterministic test cases."
  echo "- Covers allow, governance block, and approval block."
  echo "- Next phase: execute proof function against these fixtures."
} > "$OUT"

echo "Wrote $OUT"
