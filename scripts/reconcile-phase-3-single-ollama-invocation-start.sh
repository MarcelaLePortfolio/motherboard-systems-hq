#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 CORRIDOR 4 — SINGLE OLLAMA INVOCATION START ==="

classifier="scripts/classify-phase-3-single-ollama-invocation-preservation.sh"

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor 26ea2397 HEAD

echo "DR_CHECKPOINT=20260813_104707"
echo "DR_PROTECTS_CORRIDOR_3=YES"
echo "CORRIDOR_3=FAIL_CLOSED_CONTRACT_PRESERVATION"
echo "CORRIDOR_3_STATUS=COMPLETE"
echo "CORRIDOR_4=SINGLE_OLLAMA_INVOCATION"
echo "CORRIDOR_4_STATUS=STARTING_INVESTIGATION"

echo
echo "=== VERIFY EXISTING CORRIDOR 4 ARTIFACT ==="

test -f "$classifier"
echo "PRESENT=$classifier"

echo
echo "=== INSPECT EXISTING CLASSIFIER ASSUMPTIONS ==="

grep -nEi \
  'head|ancestor|ollama|invocation|retry|workflow|semantic|fail.closed|production|seed|temperature|top_p|top_k|next' \
  "$classifier" || true

echo
echo "=== VERIFY CURRENT PRODUCTION WORKFLOW ==="

production_call_count="$(
  grep -c 'await ollamaChat(message' server/matilda-chat-workflow.ts || true
)"
test "$production_call_count" -eq 1

if grep -qE \
  'validationGenerationSeed|temperature:|top_p:|top_k:|seed:' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production workflow contains explicit generation control."
  exit 2
fi

echo "PRODUCTION_WORKFLOW_OLLAMA_INVOCATIONS=$production_call_count"
echo "PRODUCTION_RETRY_POLICY=ABSENT"
echo "PRODUCTION_GENERATION_POLICY=UNCHANGED_UNCONFIGURED_UNSEEDED"

echo
echo "=== VERIFY CURRENT FAIL-CLOSED PREDECESSOR ==="

current_fail_closed="scripts/classify-current-phase-3-fail-closed-contract-preservation.sh"
test -f "$current_fail_closed"
grep -q 'FAIL_CLOSED_CONTRACT_PRESERVATION=' "$current_fail_closed"
grep -q 'COMPLETE' "$current_fail_closed"
grep -q 'SECOND_OLLAMA_INVOCATION=' "$current_fail_closed"
grep -q 'NOT_AUTHORIZED' "$current_fail_closed"

echo "FAIL_CLOSED_PREDECESSOR=COMPLETE"
echo "SECOND_OLLAMA_INVOCATION_AUTHORIZED=NO"

echo
echo "=== CORRIDOR 4 RECONCILIATION BOUNDARY ==="
echo "CORRIDOR_4_ACTIVITY=RECONCILE_EXISTING_SINGLE_INVOCATION_CLASSIFIER_WITH_CURRENT_ANCESTRY"
echo "PRODUCTION_CHANGE=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "NEXT_ACTION=CLASSIFY_SINGLE_OLLAMA_INVOCATION_ARTIFACT_CURRENTNESS"
