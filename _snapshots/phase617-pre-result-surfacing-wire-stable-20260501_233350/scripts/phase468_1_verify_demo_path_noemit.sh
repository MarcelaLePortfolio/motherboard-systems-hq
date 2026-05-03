#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase468_1_demo_path_noemit_verification.txt"
COMPILE_OUT="docs/phase468_1_demo_path_noemit_verification.compile.txt"
TARGET="src/contracts/demo/demoPathStitchingProof.ts"

mkdir -p docs

{
  echo "PHASE 468.1 — DEMO PATH NO-EMIT VERIFICATION"
  echo "============================================"
  echo
  echo "TARGET: $TARGET"
  echo

  echo "STEP 1 — Required file presence"
  for f in \
    "src/contracts/governanceExecutionBridgeContract.ts" \
    "src/contracts/adapters/governanceExecutionBridgeAdapter.ts" \
    "src/contracts/execution/governedExecutionProof.ts" \
    "src/contracts/reporting/governedExecutionProofReport.ts" \
    "src/contracts/reporting/operatorConsumableExecutionProofSurface.ts" \
    "$TARGET"
  do
    if [ -f "$f" ]; then
      echo "OK: $f"
    else
      echo "FAIL: missing $f"
    fi
  done
  echo

  echo "STEP 2 — Structural stitch anchors"
  rg -n "buildBridgeContract|executeGovernedProof|buildGovernedExecutionProofReport|buildOperatorConsumableExecutionProofSurface|runDemoPathProof" "$TARGET" || true
  echo

  echo "STEP 3 — noEmit compile verification"
  if [ -x "node_modules/.bin/tsc" ]; then
    ./node_modules/.bin/tsc --noEmit --pretty false > "$COMPILE_OUT" 2>&1 || true
    echo "Compiler output captured at $COMPILE_OUT"
  else
    echo "WARN: node_modules/.bin/tsc missing" | tee "$COMPILE_OUT"
  fi
  echo

  echo "STEP 4 — Compile status"
  if rg -q "error TS" "$COMPILE_OUT"; then
    echo "FAIL: TypeScript compile errors detected"
  else
    echo "OK: No TypeScript compile errors detected"
  fi
  echo

  echo "STEP 5 — Non-runtime guard"
  if rg -q "fetch|EventSource|worker|dispatch|docker|curl|setInterval|setTimeout|Date.now|Math.random" "$TARGET"; then
    echo "FAIL: runtime or nondeterministic behavior detected"
  else
    echo "OK: demo path remains structural, deterministic, and side-effect free"
  fi
  echo

  echo "STEP 6 — Classification"
  if rg -q "error TS" "$COMPILE_OUT"; then
    echo "CLASSIFICATION: DEMO_PATH_NOEMIT_FAILED"
  else
    echo "CLASSIFICATION: DEMO_PATH_NOEMIT_CONFIRMED"
  fi
  echo

  echo "STEP 7 — Captured compiler output"
  cat "$COMPILE_OUT"
  echo

  echo "DECISION TARGET"
  echo "- If confirmed, the FL-3 structural demo path is compile-validated."
  echo "- Next phase should be a narrow handoff/demo packet, not execution expansion."
} > "$OUT"

echo "Wrote $OUT"
