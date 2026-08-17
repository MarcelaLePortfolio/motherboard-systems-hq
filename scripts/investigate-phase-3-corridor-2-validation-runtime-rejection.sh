#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 / CORRIDOR 2 — VALIDATION RUNTIME REJECTION INVESTIGATION ==="

echo "FAILURE_CLASS=FAIL_CLOSED_SELECTED_CONTEXT_REJECTION"
echo "OBSERVED_ERROR=Ollama returned a selected context segment that was not supplied in this invocation."
echo "BEHAVIOR_CLASSIFICATION_RESULT=NOT_OBSERVED"
echo "CLASSIFICATION_RULE_FAILURE_ESTABLISHED=NO"
echo "VALIDATOR_MALFUNCTION_ESTABLISHED=NO"
echo "HYPOTHESIS_ATTEMPT_COUNT=1"
echo "PRODUCTION_CHANGE=NONE"
echo "DR_NOW=NO"

printf '\n--- SELECTED CONTEXT INPUT TYPES ---\n'
grep -n -B12 -A42 -E \
'projectContextSegmentCandidates|MatildaSelectedContextSegment|selectedContextSegments' \
scripts/utils/ollamaChat.ts | head -n 300

printf '\n--- SELECTED CONTEXT VALIDATION FAILURE SURFACE ---\n'
sed -n '980,1040p' scripts/utils/ollamaChat.ts

printf '\n--- KNOWN PASSING LIVE HARNESSES WITH PROJECT CONTEXT CANDIDATES ---\n'
grep -RIl \
'projectContextSegmentCandidates' \
scripts/*.ts scripts/utils/*.test.ts 2>/dev/null | \
head -n 20 | \
while read -r file; do
  echo "===== $file ====="
  grep -n -B12 -A35 \
    'projectContextSegmentCandidates' \
    "$file" | head -n 120
done

printf '\n--- ADAPTIVE DETAIL LIVE HARNESS ---\n'
if [ -f scripts/validate-adaptive-detail-mixed-content-live.ts ]; then
  sed -n '1,280p' scripts/validate-adaptive-detail-mixed-content-live.ts
fi

printf '\n--- CURRENT FAILED CORRIDOR 2 HARNESS ---\n'
sed -n '1,220p' scripts/validate-phase-3-corridor-2-reasoning-status-behavior.ts

cat <<'MAP'

CURRENT_DETERMINATION=
FIRST_BEHAVIOR_VALIDATION_ATTEMPT_DID_NOT_REACH_EXPLANATION_STATUS_OBSERVATION

FAILURE_OCCURRED_BEFORE_TARGET_ASSERTION=
YES

FAIL_CLOSED_BEHAVIOR=
WORKING_AS_DESIGNED_ON_OBSERVED_SURFACE

NEXT_QUESTION=
CAN_THE_BEHAVIOR_VALIDATION_HARNESS_REUSE_AN_EXISTING_VALIDATED_BOUNDED_PROJECT_CONTEXT_CANDIDATE_SURFACE_SO_MODEL_AUTHORED_SELECTION_CAN_BE_VALIDATED_WITHOUT_CHANGING_PRODUCTION_RUNTIME

DO_NOT_DO_YET=
DO_NOT_WEAKEN_SELECTED_CONTEXT_VALIDATION
DO_NOT_CHANGE_PRODUCTION_PROMPT
DO_NOT_ADD_RETRY
DO_NOT_ADD_SECOND_MODEL_CALL
DO_NOT_TREAT_FIXED_SEED_AS_PRODUCTION_POLICY

NEXT_ACTION=
INSPECT_EXISTING_PASSING_CONTEXT_CANDIDATE_FIXTURE_BEFORE_SECOND_VALIDATION_ATTEMPT
MAP
