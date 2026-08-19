#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=a2119c52' \
  'MODE=DIAGNOSTIC_ONLY' \
  'PRODUCTION_CHANGE=NONE' \
  'OLLAMA_SERVICE=HEALTHY' \
  'GEMMA3_4B=AVAILABLE' \
  'DIRECT_MODEL_GENERATION=PASS' \
  'KNOWN_FAIL_CLOSED_SURFACE=OLLAMA_CHAT_VALIDATION' \
  'TARGET=CAPTURE_EXACT_LIVE_REJECTION_WITHOUT_CHANGING_PRODUCTION'

printf '\n=== LIVE VALIDATION RUNNER SOURCE ===\n'
for file in \
  scripts/validate-adaptive-detail-mixed-content-live.ts \
  scripts/validate-support-driven-source-excerpt-live.ts \
  scripts/validate-structured-evidence-object-live.ts
do
  if [[ -f "$file" ]]; then
    echo "--- $file ---"
    sed -n '1,220p' "$file"
  fi
done

printf '\n=== RUN EXISTING UNSEEDED PRODUCTION-EQUIVALENT VALIDATION ===\n'
set +e
bash scripts/run-phase-3-repeated-unseeded-production-stability-validation.sh \
  > /tmp/matilda-live-validation.out 2>&1
status=$?
set -e

echo "VALIDATION_EXIT_STATUS=$status"

printf '\n=== EXACT LIVE FAILURE EVIDENCE ===\n'
grep -nE \
  'Error:|Ollama returned|FAIL_CLOSED_OR_RUNTIME_REJECTION|SEMANTIC_ACCEPTANCE_FAILURE|FIXTURE_SEMANTIC_PASS|FULL_SEMANTIC_PASS|selected context|support reference|investigation lifecycle' \
  /tmp/matilda-live-validation.out | tail -160 || true

printf '\n=== VALIDATION OUTPUT TAIL ===\n'
tail -160 /tmp/matilda-live-validation.out || true

printf '\n=== CLASSIFICATION RULE ===\n'
printf '%s\n' \
  'IF_PROJECT_CONTEXT_SUPPORT_NOT_SUPPLIED=CONFIRM_KNOWN_UNSEEDED_PROVENANCE_REJECTION' \
  'IF_SELECTED_CONTEXT_NOT_SUPPLIED=CONFIRM_KNOWN_UNSEEDED_SELECTION_REJECTION' \
  'IF_CONVERSATION_SUPPORT_NOT_SUPPLIED=CONFIRM_KNOWN_UNSEEDED_HISTORY_PROVENANCE_REJECTION' \
  'IF_INVESTIGATION_CONTINUITY_REJECTION=CLASSIFY_LIFECYCLE_CONTINUITY_FAILURE' \
  'IF_STRUCTURED_RESPONSE_REJECTION=CLASSIFY_STRUCTURED_OUTPUT_FAILURE' \
  'IF_NO_REJECTION=UI_REQUEST_SPECIFIC_CONTEXT_MAY_BE_REQUIRED' \
  'VALIDATOR_WEAKENING_AUTHORIZED=NO' \
  'PRODUCTION_GENERATION_CONTROL_CHANGE_AUTHORIZED=NO' \
  'NEXT_ACTION=CLASSIFY_EXACT_OBSERVED_REJECTION'

printf '\n=== WORKTREE ===\n'
git status --short
