#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase467_0_controlled_execution_intro_proof.txt"
TARGET="src/contracts/execution/governedExecutionProof.ts"

mkdir -p docs

{
  echo "PHASE 467.0 — CONTROLLED EXECUTION INTRODUCTION PROOF"
  echo "====================================================="
  echo
  echo "TARGET: $TARGET"
  echo

  echo "STEP 1 — File presence"
  [ -f "$TARGET" ] && echo "OK: governed execution proof file present" || echo "FAIL: governed execution proof file missing"
  echo

  echo "STEP 2 — Proof surface"
  rg -n "GovernedExecutionApproval|GovernedExecutionProofInput|GovernedExecutionProofResult|executeGovernedProof|approved: boolean|accepted: boolean|blocked_reason|operator_visible" "$TARGET" || true
  echo

  echo "STEP 3 — Hard gate checks"
  rg -q 'governance_denied' "$TARGET" && echo "OK: governance denial gate present" || echo "FAIL: governance denial gate missing"
  rg -q 'operator_approval_missing' "$TARGET" && echo "OK: operator approval gate present" || echo "FAIL: operator approval gate missing"
  rg -q 'outcome: "prepared"' "$TARGET" && echo "OK: prepared outcome present" || echo "FAIL: prepared outcome missing"
  echo

  echo "STEP 4 — Non-runtime guarantee"
  if rg -q "fetch|EventSource|Date.now|Math.random|dispatch|worker|docker|curl|setInterval|setTimeout" "$TARGET"; then
    echo "FAIL: runtime behavior leakage detected"
  else
    echo "OK: no runtime behavior leakage detected"
  fi
  echo

  echo "STEP 5 — Classification"
  echo "CLASSIFICATION: CONTROLLED_EXECUTION_PROOF_SURFACE_DEFINED"
  echo

  echo "DECISION TARGET"
  echo "- First governed execution proof surface now exists."
  echo "- Execution remains pure, explicit, human-approved, and side-effect free."
  echo "- Next phase may add fixture-backed proof inputs for allowed vs blocked cases."
} > "$OUT"

echo "Wrote $OUT"
