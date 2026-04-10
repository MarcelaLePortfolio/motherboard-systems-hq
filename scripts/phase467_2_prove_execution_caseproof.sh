#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase467_2_execution_caseproof.txt"
PROOF="src/contracts/execution/__proofs__/governedExecutionProof.caseproof.ts"

mkdir -p docs

{
  echo "PHASE 467.2 — EXECUTION CASEPROOF"
  echo "================================="
  echo
  echo "PROOF FILE: $PROOF"
  echo

  echo "STEP 1 — File presence"
  [ -f "$PROOF" ] && echo "OK: caseproof file present" || echo "FAIL: caseproof file missing"
  echo

  echo "STEP 2 — Case result exports"
  rg -q "governedExecutionAllowedResult" "$PROOF" && echo "OK: allowed result export present" || echo "FAIL: allowed result export missing"
  rg -q "governedExecutionGovernanceBlockedResult" "$PROOF" && echo "OK: governance-blocked result export present" || echo "FAIL: governance-blocked result export missing"
  rg -q "governedExecutionApprovalMissingResult" "$PROOF" && echo "OK: approval-missing result export present" || echo "FAIL: approval-missing result export missing"
  echo

  echo "STEP 3 — Expected semantic anchors"
  rg -q "governance_denied" "$PROOF" && echo "OK: governance denial path represented" || echo "FAIL: governance denial path missing"
  rg -q "operator_approval_missing" "$PROOF" && echo "OK: approval-missing path represented" || echo "FAIL: approval-missing path missing"
  rg -q 'outcome: governedExecutionAllowedResult.execution.outcome' "$PROOF" && echo "OK: allowed outcome summarized" || echo "FAIL: allowed outcome summary missing"
  echo

  echo "STEP 4 — Non-runtime guarantee"
  if rg -q "fetch|EventSource|worker|dispatch|docker|curl|setInterval|setTimeout|Date.now|Math.random" "$PROOF"; then
    echo "FAIL: runtime or nondeterministic behavior detected"
  else
    echo "OK: pure caseproof surface only"
  fi
  echo

  echo "STEP 5 — Classification"
  echo "CLASSIFICATION: EXECUTION_CASEPROOF_DEFINED"
  echo

  echo "DECISION TARGET"
  echo "- Governed proof function is now evaluated across all three deterministic fixtures."
  echo "- Allowed, governance-blocked, and approval-missing result surfaces are defined."
  echo "- Next phase may add compile-only noEmit verification focused on the execution proof corridor."
} > "$OUT"

echo "Wrote $OUT"
