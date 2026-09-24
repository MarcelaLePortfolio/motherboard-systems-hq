#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="36f346640"
UI="client/src/approvals/ApprovalsWorkspace.tsx"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n====================================================\n'
printf ' EXPLICIT OPERATOR ENVELOPE GATE — ATTEMPT 1 MISS\n'
printf '====================================================\n\n'

echo "ATTEMPT_1_STATUS=FAILED"
echo "FAILURE_REASON=POST_GOVERNANCE_VALIDATION_SYMBOL_NOT_FOUND"
echo "FAILED_ATTEMPTS=1"
echo "PATCH_FORWARD=NO"
echo "TARGETS_RESTORED=YES"
echo "IMPLEMENTATION_LANDED=NO"

printf '\n=== UI TARGET CLEANNESS ===\n'
test -z "$(git status --porcelain -- "$UI")"
test ! -e client/src/approvals/governanceEnvelopeGateApi.ts
test ! -e client/src/approvals/governanceEnvelopeGateApi.test.ts
echo "UI_TARGET_CLEAN=YES"
echo "NEW_API_TARGET_ABSENT=YES"
echo "NEW_TEST_TARGET_ABSENT=YES"

printf '\n=== ACTUAL VALIDATION API IMPORTS ===\n'
grep -nE \
  'governanceValidationApi|submitGovernanceValidation|Validation' \
  "$UI" \
  | head -n 220 || true

printf '\n=== ACTUAL VALIDATION HANDLER REGION ===\n'
grep -nE \
  'crypto\.randomUUID|validation_result_id|validation_status|delegation_id|Validate|validat' \
  "$UI" \
  | head -n 260 || true

printf '\n=== CONTEXT AROUND VALIDATION ID CREATION ===\n'
LINE="$(grep -n 'validation_result_id' "$UI" | head -n 1 | cut -d: -f1 || true)"
if [ -n "$LINE" ]; then
  START=$(( LINE > 80 ? LINE - 80 : 1 ))
  END=$(( LINE + 140 ))
  sed -n "${START},${END}p" "$UI"
fi

printf '\n=== CONTEXT AROUND VALIDATE BUTTON ===\n'
LINE="$(grep -n 'Validate' "$UI" | head -n 1 | cut -d: -f1 || true)"
if [ -n "$LINE" ]; then
  START=$(( LINE > 80 ? LINE - 80 : 1 ))
  END=$(( LINE + 120 ))
  sed -n "${START},${END}p" "$UI"
fi

printf '\n=== IMPORT BLOCK ===\n'
sed -n '1,120p' "$UI"

printf '\n=== ATTEMPT 2 REQUIREMENT ===\n'
echo "USE_ACTUAL_VALIDATION_HANDLER_SYMBOLS=YES"
echo "NO_GUESSED_FUNCTION_NAMES=YES"
echo "KEEP_TARGET_COUNT=3"
echo "SERVER_CHANGE=NO"
echo "DATABASE_CHANGE=NO"
echo "SCHEMA_CHANGE=NO"
echo "LIVE_GATE_INVOCATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "AUTOMATIC_VALIDATION_TO_GATE_TRANSITION=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"

printf '\nNEXT_ACTION=BUILD_ATTEMPT_2_FROM_EXACT_UI_ANCHORS\n'
