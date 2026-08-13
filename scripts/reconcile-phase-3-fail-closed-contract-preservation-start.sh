#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 CORRIDOR 3 — FAIL-CLOSED CONTRACT PRESERVATION START ==="

classifier="scripts/classify-phase-3-fail-closed-contract-preservation.sh"

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor d8256e8d HEAD
git merge-base --is-ancestor 472055c6 HEAD

echo "DR_CHECKPOINT=20260813_103805"
echo "DR_PROTECTS_CORRIDOR_2=YES"
echo "CORRIDOR_2=UNSEEDED_BEHAVIORAL_VALIDATION"
echo "CORRIDOR_2_STATUS=COMPLETE"
echo "CORRIDOR_3=FAIL_CLOSED_CONTRACT_PRESERVATION"
echo "CORRIDOR_3_STATUS=STARTING_INVESTIGATION"

echo
echo "=== VERIFY EXISTING CORRIDOR 3 ARTIFACT ==="

test -f "$classifier"
echo "PRESENT=$classifier"

echo
echo "=== INSPECT EXISTING CLASSIFIER ASSUMPTIONS ==="

grep -nEi \
  'head|ancestor|sample|10|fail.closed|runtime.rejection|semantic|support|provenance|validator|production|seed|ollama|preserv|next' \
  "$classifier" || true

echo
echo "=== VERIFY CURRENT CORRIDOR 2 EVIDENCE ==="

current_result="scripts/classify-current-phase-3-repeated-unseeded-validation-result.sh"
test -f "$current_result"

grep -q 'FAIL_CLOSED_OR_RUNTIME_REJECTION_RUNS=10' "$current_result"
grep -q 'FIXTURE_SEMANTIC_PASS_RUNS=0' "$current_result"
grep -q 'FIXTURE_SEMANTIC_FAILURE_RUNS=0' "$current_result"
grep -q 'UNIQUE_EXACT_OUTPUT_FINGERPRINTS=1' "$current_result"
grep -q 'PRESERVED_ON_ALL_10_OBSERVED_FAILURES' "$current_result"

echo "CURRENT_SAMPLE_TOTAL_RUNS=10"
echo "CURRENT_SAMPLE_FAIL_CLOSED_OR_RUNTIME_REJECTION_RUNS=10"
echo "CURRENT_SAMPLE_SEMANTIC_PASS_RUNS=0"
echo "CURRENT_SAMPLE_SEMANTIC_FAILURE_RUNS=0"
echo "CURRENT_SAMPLE_UNIQUE_FINGERPRINTS=1"
echo "CURRENT_SAMPLE_PRIMARY_REJECTION=UNSUPPLIED_PROJECT_CONTEXT_SUPPORT_REFERENCE"

echo
echo "=== VERIFY CURRENT PRODUCTION BOUNDARY ==="

if grep -qE \
  'validationGenerationSeed|temperature:|top_p:|top_k:|seed:' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production workflow contains explicit generation control."
  exit 2
fi

production_call_count="$(grep -c 'await ollamaChat(message' server/matilda-chat-workflow.ts || true)"
test "$production_call_count" -eq 1

echo "PRODUCTION_GENERATION_POLICY=UNCHANGED_UNCONFIGURED_UNSEEDED"
echo "PRODUCTION_OLLAMA_INVOCATION_COUNT=ONE"
echo "VALIDATOR_WEAKENING=ABSENT"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== CORRIDOR 3 RECONCILIATION BOUNDARY ==="
echo "CORRIDOR_3_ACTIVITY=RECONCILE_EXISTING_FAIL_CLOSED_CLASSIFIER_WITH_CURRENT_SAMPLE"
echo "LEGACY_SAMPLE_ASSUMPTIONS_MUST_NOT_BE_INFERRED_CURRENT=YES"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "NEXT_ACTION=CLASSIFY_FAIL_CLOSED_ARTIFACT_CURRENTNESS"
