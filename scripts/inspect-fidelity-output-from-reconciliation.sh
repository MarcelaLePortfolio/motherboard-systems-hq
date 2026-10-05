#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="7fa416365"
TARGET="scripts/utils/ollamaChat.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "=== FIDELITY IMPLEMENTATION — DECISIVE READ ==="

echo
echo "=== EXACT FIDELITY FUNCTION ==="
START="$(
  grep -n 'function enforceConcreteOperationPackageSemanticsFidelity' "$TARGET" \
    | head -1 \
    | cut -d: -f1 \
    || true
)"

if [ -z "$START" ]; then
  START="$(
    grep -n 'enforceConcreteOperationPackageSemanticsFidelity' "$TARGET" \
      | head -1 \
      | cut -d: -f1 \
      || true
  )"
fi

if [ -z "$START" ]; then
  echo "FIDELITY_FUNCTION_FOUND=NO"
  exit 1
fi

echo "FIDELITY_FUNCTION_FOUND=YES"
echo "FIDELITY_FUNCTION_START_LINE=$START"

END=$((START + 120))
sed -n "${START},${END}p" "$TARGET"

echo
echo "=== OPERATION MATCHING LOGIC ==="
grep -n -B20 -A40 -E \
  'operationTerms|operationSemanticTerms|preservesOperation|preservesSubject' \
  "$TARGET" | head -320 || true

echo
echo "=== REMOVE / RESTORE HANDLING ==="
grep -n -B12 -A30 -Ei \
  'remove|removed|restore|restored' \
  "$TARGET" | head -320 || true

echo
echo "=== ESTABLISHED LIVE EVIDENCE ==="
echo "REQUEST_OPERATION=remove"
echo "REQUEST_SUBJECT=packages tab"
echo "REQUEST_PRESERVATION_BOUNDARY=underlying package runtime functionality and authority"
echo "MODEL_AUTHORED_EXPECTEDOUTCOME=Canonical Package visibility restored"
echo "FIDELITY_RESULT=REJECTED"
echo "FAIL_CLOSED_BEHAVIOR=CONFIRMED"

echo
echo "=== DECISION QUESTION ==="
echo "QUESTION=DOES_CURRENT_FIDELITY_LOGIC_EXPLICITLY_MODEL_OPERATION_DIRECTION_OR_ONLY_REQUIRE_OPERATION_AND_SUBJECT_OVERLAP"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "DOGFOOD_RETRY=NO"
echo "VALIDATOR_RELAXATION=NO"

echo
echo "=== SAFETY ==="
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
echo "TARGET_CODE_MUTATION=NONE"
echo "DATABASE_MUTATION=NONE"
echo "UNRELATED_WORKTREE_PRESERVED=YES"
