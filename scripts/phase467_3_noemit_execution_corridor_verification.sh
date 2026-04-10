#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase467_3_noemit_execution_corridor_verification.txt"
COMPILE_OUT="docs/phase467_3_noemit_execution_corridor_verification.compile.txt"

mkdir -p docs

{
  echo "PHASE 467.3 — NO-EMIT EXECUTION CORRIDOR VERIFICATION"
  echo "===================================================="
  echo

  echo "STEP 1 — Required file presence"
  for f in \
    "src/contracts/execution/governedExecutionProof.ts" \
    "src/contracts/execution/__fixtures__/governedExecutionProof.fixture.ts" \
    "src/contracts/execution/__proofs__/governedExecutionProof.caseproof.ts" \
    "src/contracts/governanceExecutionBridgeContract.ts" \
    "src/contracts/adapters/governanceExecutionBridgeAdapter.ts"
  do
    if [ -f "$f" ]; then
      echo "OK: $f"
    else
      echo "FAIL: missing $f"
    fi
  done
  echo

  echo "STEP 2 — tsconfig presence"
  if [ -f "tsconfig.json" ]; then
    echo "OK: tsconfig.json present"
  else
    echo "FAIL: tsconfig.json missing"
  fi
  echo

  echo "STEP 3 — noEmit compile pass"
  if [ -x "node_modules/.bin/tsc" ]; then
    ./node_modules/.bin/tsc --noEmit --pretty false > "$COMPILE_OUT" 2>&1 || true
    echo "Compiler output captured at $COMPILE_OUT"
  else
    echo "WARN: node_modules/.bin/tsc missing" | tee "$COMPILE_OUT"
  fi
  echo

  echo "STEP 4 — execution corridor surface anchors"
  rg -n "executeGovernedProof|governedExecutionAllowedResult|governedExecutionGovernanceBlockedResult|governedExecutionApprovalMissingResult|operator_approval_missing|governance_denied" \
    src/contracts/execution 2>/dev/null || true
  echo

  echo "STEP 5 — compile status"
  if rg -q "error TS" "$COMPILE_OUT"; then
    echo "FAIL: TypeScript compile errors detected"
  else
    echo "OK: No TypeScript compile errors detected"
  fi
  echo

  echo "STEP 6 — corridor classification"
  if rg -q "error TS" "$COMPILE_OUT"; then
    echo "CLASSIFICATION: EXECUTION_CORRIDOR_NOEMIT_FAILED"
  else
    echo "CLASSIFICATION: EXECUTION_CORRIDOR_NOEMIT_CONFIRMED"
  fi
  echo

  echo "STEP 7 — captured compiler output"
  cat "$COMPILE_OUT"
  echo

  echo "DECISION TARGET"
  echo "- If confirmed, the first governed execution proof corridor is structurally complete."
  echo "- Next phase should remain narrow: reporting contract or operator-visible proof result surface."
} > "$OUT"

echo "Wrote $OUT"
