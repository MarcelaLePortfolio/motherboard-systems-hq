#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 CORRIDOR 2 — UNSEEDED BEHAVIORAL VALIDATION START ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor d8256e8d HEAD

echo "DR_CHECKPOINT=20260813_102951"
echo "DR_PROTECTS_CORRIDOR_1=YES"
echo "CORRIDOR_1=PRODUCTION_STABILITY_CONTRACT"
echo "CORRIDOR_1_STATUS=COMPLETE"
echo "CORRIDOR_2=UNSEEDED_BEHAVIORAL_VALIDATION"
echo "CORRIDOR_2_STATUS=STARTING_INVESTIGATION"

echo
echo "=== VERIFY CORRIDOR 2 EXISTING ARTIFACTS ==="

artifacts=(
  "scripts/classify-phase-3-repeated-unseeded-validation-fixture-and-runner.sh"
  "scripts/run-phase-3-repeated-unseeded-production-stability-validation.sh"
  "scripts/classify-phase-3-repeated-unseeded-validation-result.sh"
)

for artifact in "${artifacts[@]}"; do
  test -f "$artifact"
  echo "PRESENT=$artifact"
done

echo
echo "=== VERIFY UNSEEDED BOUNDARY ==="

fixture="$(grep -l 'EXISTING_ADAPTIVE_DETAIL_MIXED_CONTENT_LIVE_FIXTURE' scripts/classify-phase-3-repeated-unseeded-validation-fixture-and-runner.sh scripts/define-phase-3-production-stability-validation-contract.sh | head -1)"
echo "CONTRACT_REFERENCE_SOURCE=$fixture"

grep -nEi \
  'fixture|unseed|validationGenerationSeed|sample|10_|retry|production|ollama|semantic|fail.closed|fingerprint|next.action' \
  scripts/classify-phase-3-repeated-unseeded-validation-fixture-and-runner.sh

echo
echo "=== RUNNER RECONCILIATION EVIDENCE ==="

grep -nEi \
  'validationGenerationSeed|temperature:|top_p:|top_k:|seed:|10|retry|ollama|semantic|fail.closed|fingerprint|production|next.action' \
  scripts/run-phase-3-repeated-unseeded-production-stability-validation.sh

echo
echo "=== CURRENT PRODUCTION CONTROL GUARD ==="

if grep -qE 'validationGenerationSeed|temperature:|top_p:|top_k:|seed:' server/matilda-chat-workflow.ts; then
  echo "STOP: production generation control detected."
  exit 2
fi

production_call_count="$(grep -c 'await ollamaChat(message' server/matilda-chat-workflow.ts || true)"
test "$production_call_count" -eq 1

echo "PRODUCTION_GENERATION_POLICY=UNCHANGED_UNCONFIGURED_UNSEEDED"
echo "PRODUCTION_OLLAMA_INVOCATION_COUNT=ONE"
echo "VALIDATION_SEED_PROMOTION=ABSENT"
echo "PRODUCTION_POLICY_CHANGE=NONE"
echo "CORRIDOR_2_ACTIVITY=RECONCILE_EXISTING_UNSEEDED_FIXTURE_AND_RUNNER"
echo "REPEATED_SAMPLE_EXECUTION=NOT_YET_STARTED"
echo "NEXT_ACTION=CLASSIFY_CORRIDOR_2_FIXTURE_AND_RUNNER_CURRENTNESS"
