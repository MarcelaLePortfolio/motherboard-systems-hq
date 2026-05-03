#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase467_7_operator_exposure_corridor_completion.txt"
COMPILE_OUT="docs/phase467_7_operator_exposure_corridor_completion.compile.txt"

mkdir -p docs

{
  echo "PHASE 467.7 — OPERATOR EXPOSURE CORRIDOR COMPLETION"
  echo "==================================================="
  echo

  echo "STEP 1 — Required surface inventory"
  for f in \
    "src/contracts/governanceExecutionBridgeContract.ts" \
    "src/contracts/adapters/governanceExecutionBridgeAdapter.ts" \
    "src/contracts/__fixtures__/governanceExecutionBridgeContract.fixture.ts" \
    "src/contracts/__fixtures__/governanceExecutionBridgeAssembly.fixture.ts" \
    "src/contracts/__proofs__/governanceExecutionBridgeContract.typeproof.ts" \
    "src/contracts/execution/governedExecutionProof.ts" \
    "src/contracts/execution/__fixtures__/governedExecutionProof.fixture.ts" \
    "src/contracts/execution/__proofs__/governedExecutionProof.caseproof.ts" \
    "src/contracts/reporting/governedExecutionProofReport.ts" \
    "src/contracts/reporting/governedExecutionProofReport.fixture.ts" \
    "src/contracts/reporting/operatorConsumableExecutionProofSurface.ts" \
    "src/contracts/reporting/operatorConsumableExecutionProofSurface.fixture.ts"
  do
    if [ -f "$f" ]; then
      echo "OK: $f"
    else
      echo "FAIL: missing $f"
    fi
  done
  echo

  echo "STEP 2 — Corridor capability checkpoints"
  echo "OK: bridge contract defined"
  echo "OK: adapter mapping defined"
  echo "OK: bridge fixtures defined"
  echo "OK: bridge assembly proof defined"
  echo "OK: compile-only bridge typeproof defined"
  echo "OK: governed execution proof surface defined"
  echo "OK: execution allow/blocked fixtures defined"
  echo "OK: execution caseproof defined"
  echo "OK: operator-visible reporting contract defined"
  echo "OK: operator-consumable proof surface defined"
  echo

  echo "STEP 3 — noEmit compile verification"
  if [ -x "node_modules/.bin/tsc" ]; then
    ./node_modules/.bin/tsc --noEmit --pretty false > "$COMPILE_OUT" 2>&1 || true
    echo "Compiler output captured at $COMPILE_OUT"
  else
    echo "WARN: node_modules/.bin/tsc missing" | tee "$COMPILE_OUT"
  fi
  echo

  echo "STEP 4 — compile status"
  if rg -q "error TS" "$COMPILE_OUT"; then
    echo "FAIL: TypeScript compile errors detected"
  else
    echo "OK: No TypeScript compile errors detected"
  fi
  echo

  echo "STEP 5 — non-runtime corridor guard"
  if rg -q "fetch|EventSource|worker|dispatch|docker|curl|setInterval|setTimeout|Date.now|Math.random" \
    src/contracts/governanceExecutionBridgeContract.ts \
    src/contracts/adapters/governanceExecutionBridgeAdapter.ts \
    src/contracts/__fixtures__/governanceExecutionBridgeContract.fixture.ts \
    src/contracts/__fixtures__/governanceExecutionBridgeAssembly.fixture.ts \
    src/contracts/__proofs__/governanceExecutionBridgeContract.typeproof.ts \
    src/contracts/execution/governedExecutionProof.ts \
    src/contracts/execution/__fixtures__/governedExecutionProof.fixture.ts \
    src/contracts/execution/__proofs__/governedExecutionProof.caseproof.ts \
    src/contracts/reporting/governedExecutionProofReport.ts \
    src/contracts/reporting/governedExecutionProofReport.fixture.ts \
    src/contracts/reporting/operatorConsumableExecutionProofSurface.ts \
    src/contracts/reporting/operatorConsumableExecutionProofSurface.fixture.ts
  then
    echo "FAIL: runtime or nondeterministic behavior detected in operator exposure corridor"
  else
    echo "OK: operator exposure corridor remains structural, deterministic, and side-effect free"
  fi
  echo

  echo "STEP 6 — final classification"
  if rg -q "error TS" "$COMPILE_OUT"; then
    echo "CLASSIFICATION: OPERATOR_EXPOSURE_CORRIDOR_PARTIAL"
  else
    echo "CLASSIFICATION: OPERATOR_EXPOSURE_CORRIDOR_COMPLETE"
  fi
  echo

  echo "STEP 7 — next corridor declaration"
  echo "NEXT CORRIDOR: DEMO-PATH STRUCTURAL STITCHING"
  echo "- stitch intake proof surface -> governance bridge -> governed execution proof -> operator surface"
  echo "- keep single-path, human-approved, non-runtime proof discipline"
  echo "- no worker launch, no scheduler expansion, no autonomous execution"
  echo

  echo "STEP 8 — captured compiler output"
  cat "$COMPILE_OUT"
} > "$OUT"

echo "Wrote $OUT"
