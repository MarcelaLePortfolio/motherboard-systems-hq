#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 / CORRIDOR 2 — PRE-VALIDATION SELECTED CONTEXT OBSERVABILITY ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"

cat <<'MAP'
ATTEMPT_1=FAIL_CLOSED_SELECTED_CONTEXT_REJECTION
ATTEMPT_2=FAIL_CLOSED_SELECTED_CONTEXT_REJECTION
TARGET_EXPLANATION_STATUS_OBSERVED=NO
THIRD_ATTEMPT_AUTHORIZED=NO
CURRENT_BOUNDARY=INVESTIGATION_ONLY
QUESTION=CAN_MODEL_AUTHORED_SELECTED_CONTEXT_BE_OBSERVED_BEFORE_MEMBERSHIP_VALIDATION_WITHOUT_CHANGING_PRODUCTION_SEMANTICS
PRODUCTION_CHANGE=NONE
DR_NOW=NO
MAP

printf '\n--- PARSE / VALIDATION CALL ORDER ---\n'
sed -n '940,1045p' scripts/utils/ollamaChat.ts

printf '\n--- ALL SELECTED-CONTEXT OBSERVER SEAMS ---\n'
grep -RIn -B20 -A45 -E \
'observeValidatedSelectedContextSegments|selectedContextSegments.*observer|observe.*SelectedContext|parseStructuredResponse' \
scripts server \
--exclude-dir=node_modules \
2>/dev/null | head -n 650

printf '\n--- PARSED SUPPORT PRE-VALIDATION OBSERVER FOR COMPARISON ---\n'
grep -n -B25 -A45 \
'observeParsedSupportSourceReferences' \
scripts/utils/ollamaChat.ts

printf '\n--- HISTORY OF SELECTED-CONTEXT OBSERVABILITY ---\n'
git log --all --oneline --decorate -- \
scripts/utils/ollamaChat.ts \
scripts/utils/ollamaChat.selected-context-observer.test.ts \
scripts/document-adaptive-detail-behavioral-observability-block.sh | head -n 120

printf '\n--- BEHAVIORAL OBSERVABILITY ARCHITECTURAL DETERMINATION ---\n'
if [ -f scripts/document-adaptive-detail-behavioral-observability-block.sh ]; then
  sed -n '1,240p' scripts/document-adaptive-detail-behavioral-observability-block.sh
fi

cat <<'MAP'

NEXT_DETERMINATION=
ESTABLISH_WHETHER_AN_EXISTING_PRE_VALIDATION_OBSERVATION_SEAM_ALREADY_EXISTS

IF_NO_EXISTING_SEAM=
DO_NOT_ADD_ONE_AUTOMATICALLY
CLASSIFY_WHETHER_DIAGNOSTIC_OBSERVABILITY_IS_REQUIRED_BEFORE_ANY_THIRD_ATTEMPT

DO_NOT_CHANGE=
FAIL_CLOSED_MEMBERSHIP_VALIDATION
PRODUCTION_PROMPT
STRUCTURED_SCHEMA
RETRY_POLICY
MODEL_INVOCATION_COUNT

NEXT_ACTION=
CLASSIFY_SELECTED_CONTEXT_PRE_VALIDATION_OBSERVABILITY_BOUNDARY
MAP
