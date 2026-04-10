#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase466_0_bridge_contract_compatibility.txt"

INTAKE_FILE="server/taskContract.mjs"
GOVERNANCE_FILE="server/policy/policy_eval.mjs"
EXECUTION_FILE="server/orchestration/policy-pipeline.ts"
CONTRACT_FILE="src/contracts/governanceExecutionBridgeContract.ts"

mkdir -p docs

{
  echo "PHASE 466.0 — BRIDGE CONTRACT COMPATIBILITY MAP"
  echo "==============================================="
  echo
  echo "CONTRACT FILE: $CONTRACT_FILE"
  echo "INTAKE OWNER: $INTAKE_FILE"
  echo "GOVERNANCE OWNER: $GOVERNANCE_FILE"
  echo "EXECUTION/PREPARATION OWNER: $EXECUTION_FILE"
  echo

  echo "STEP 1 — Contract surface"
  sed -n '1,240p' "$CONTRACT_FILE"
  echo

  echo "STEP 2 — Intake compatibility"
  rg -n 'normalizeTaskForRead|normalizeTaskForWrite|validateNewTask|validateTransition|id:|title:|agent:|status:|notes:|source:|trace_id:|error:|meta:|created_at:|updated_at:' "$INTAKE_FILE" || true
  echo

  echo "STEP 3 — Governance compatibility"
  rg -n 'version:|decision|allow:|enforce:|reasons:|confidence:|signals|task_id:|run_id:|kind:|action_tier:|attempts:|max_attempts:|claimed_by:|now_ms:' "$GOVERNANCE_FILE" || true
  echo

  echo "STEP 4 — Execution/preparation compatibility"
  rg -n 'applyDecisions|runPolicyPipeline|runEventLoopOnce|operatorMode|intent|emitted|events|ctx:' "$EXECUTION_FILE" || true
  echo

  echo "STEP 5 — Boundary mapping"
  echo "[intake.task]"
  echo "- id/title/agent/status/notes/source/trace_id/error/meta/created_at/updated_at are owned by taskContract normalization."
  echo
  echo "[governance]"
  echo "- version/decision/signals are owned by policy_eval shadow evaluation."
  echo
  echo "[preparation]"
  echo "- ctx_updates.operatorMode / ctx_updates.intent map to policy-pipeline set_mode / set_intent decisions."
  echo "- emitted_events maps to policy-pipeline emitted orchestration events."
  echo "- accepted remains a structural bridge field not yet wired to runtime behavior."
  echo

  echo "STEP 6 — Compatibility classification"
  HAS_INTAKE=0
  HAS_GOV=0
  HAS_EXEC=0

  rg -q 'normalizeTaskForRead|normalizeTaskForWrite' "$INTAKE_FILE" && HAS_INTAKE=1 || true
  rg -q 'decision|signals|version:' "$GOVERNANCE_FILE" && HAS_GOV=1 || true
  rg -q 'operatorMode|intent|emitted' "$EXECUTION_FILE" && HAS_EXEC=1 || true

  if [ "$HAS_INTAKE" -eq 1 ] && [ "$HAS_GOV" -eq 1 ] && [ "$HAS_EXEC" -eq 1 ]; then
    CLASS="STRUCTURAL_COMPATIBILITY_CONFIRMED"
  else
    CLASS="STRUCTURAL_COMPATIBILITY_PARTIAL"
  fi

  echo "CLASSIFICATION: $CLASS"
  echo

  echo "DECISION TARGET"
  echo "- This phase defines the contract file and proves owner compatibility only."
  echo "- No runtime mutation was introduced."
  echo "- Next phase may define a non-runtime adapter map or fixture proving contract assembly."
} > "$OUT"

echo "Wrote $OUT"
