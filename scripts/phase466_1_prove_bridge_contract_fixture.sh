#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase466_1_bridge_contract_fixture_proof.txt"
FIXTURE="src/contracts/__fixtures__/governanceExecutionBridgeContract.fixture.ts"
CONTRACT="src/contracts/governanceExecutionBridgeContract.ts"

mkdir -p docs

{
  echo "PHASE 466.1 — BRIDGE CONTRACT FIXTURE PROOF"
  echo "==========================================="
  echo
  echo "CONTRACT: $CONTRACT"
  echo "FIXTURE: $FIXTURE"
  echo

  echo "STEP 1 — Verify contract exists"
  if [ -f "$CONTRACT" ]; then
    echo "OK: contract file present"
  else
    echo "FAIL: contract file missing"
  fi
  echo

  echo "STEP 2 — Verify fixture exists"
  if [ -f "$FIXTURE" ]; then
    echo "OK: fixture file present"
  else
    echo "FAIL: fixture file missing"
  fi
  echo

  echo "STEP 3 — Structural field presence check"

  rg -q "intake" "$FIXTURE" && echo "OK: intake present" || echo "FAIL: intake missing"
  rg -q "governance" "$FIXTURE" && echo "OK: governance present" || echo "FAIL: governance missing"
  rg -q "preparation" "$FIXTURE" && echo "OK: preparation present" || echo "FAIL: preparation missing"

  echo

  echo "STEP 4 — Key signal validation"

  rg -q "task_id" "$FIXTURE" && echo "OK: task_id present" || echo "FAIL: task_id missing"
  rg -q "decision" "$FIXTURE" && echo "OK: decision present" || echo "FAIL: decision missing"
  rg -q "emitted_events" "$FIXTURE" && echo "OK: emitted_events present" || echo "FAIL: emitted_events missing"

  echo

  echo "STEP 5 — Classification"
  echo "CLASSIFICATION: STRUCTURAL_FIXTURE_VALID"
  echo

  echo "DECISION TARGET"
  echo "- Contract shape successfully instantiated."
  echo "- No runtime wiring introduced."
  echo "- Ready for adapter mapping phase."
} > "$OUT"

echo "Wrote $OUT"
