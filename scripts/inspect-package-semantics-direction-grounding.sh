#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="03dd69bb9"
TARGET="scripts/utils/ollamaChat.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test -z "$(git status --porcelain)"

echo "=== PACKAGE SEMANTICS DIRECTION GROUNDING — INSPECTION ==="

echo
echo "=== ESTABLISHED EVIDENCE ==="
echo "REQUESTED_OPERATION=remove"
echo "REQUESTED_SUBJECT=packages tab"
echo "REQUESTED_CONSTRAINT=preserve underlying package runtime functionality and authority"
echo "MODEL_EXPECTEDOUTCOME=Canonical Package visibility restored"
echo "SEMANTIC_DIRECTION_INVERSION=CONFIRMED"
echo "FIDELITY_REJECTION=CORRECT"

echo
echo "=== PROMPT CONTRACT AROUND PACKAGE SEMANTICS ==="
sed -n '1338,1368p' "$TARGET"

echo
echo "=== SEARCH FOR DIRECTION-PRESERVATION INSTRUCTIONS ==="
if grep -nEi \
  'preserve.*(operation|direction)|operation.*direction|requested.*operation|remove.*expectedOutcome|expectedOutcome.*remove|opposite|invert' \
  "$TARGET"; then
  echo "EXPLICIT_DIRECTION_GROUNDING_LANGUAGE_FOUND=YES"
else
  echo "EXPLICIT_DIRECTION_GROUNDING_LANGUAGE_FOUND=NO"
fi

echo
echo "=== HISTORICAL INTRODUCTION OF PACKAGE SEMANTICS PROMPT ==="
git show --stat --oneline 881c35513
git show 881c35513 -- "$TARGET" | sed -n '1,260p'

echo
echo "=== REQUIRE-PACKAGE-SEMANTICS CHANGE ==="
git show --stat --oneline a3ef61c0e
git show a3ef61c0e -- "$TARGET" | sed -n '1,320p'

echo
echo "=== FIDELITY-GUARD CHANGE ==="
git show --stat --oneline f9106a9d8
git show f9106a9d8 -- "$TARGET" | sed -n '1,360p'

echo
echo "=== CLASSIFICATION ==="
echo "MODEL_OUTPUT_STRUCTURALLY_VALID=YES"
echo "MODEL_OUTPUT_REQUEST_DIRECTION_VALID=NO"
echo "CURRENT_PROMPT_REQUIRES_REQUEST_GROUNDING=YES"
echo "CURRENT_PROMPT_REQUIRES_REQUEST_SPECIFIC_EXPECTEDOUTCOME=YES"

if grep -qEi \
  'preserve.*(operation|direction)|operation.*direction|requested.*operation|opposite|invert' \
  "$TARGET"; then
  echo "CURRENT_PROMPT_EXPLICITLY_REQUIRES_OPERATION_DIRECTION_PRESERVATION=YES"
  echo "ROOT_CAUSE_CLASSIFICATION=MODEL_FAILED_EXPLICIT_DIRECTION_CONTRACT"
  echo "NEXT_ACTION=ASSESS_NARROW_DETERMINISTIC_DIRECTION_ENFORCEMENT"
else
  echo "CURRENT_PROMPT_EXPLICITLY_REQUIRES_OPERATION_DIRECTION_PRESERVATION=NO"
  echo "ROOT_CAUSE_CLASSIFICATION=PROMPT_GROUNDING_GAP_FOR_OPERATION_DIRECTION"
  echo "NEXT_ACTION=REQUEST_AUTHORIZATION_FOR_NARROW_EXPECTEDOUTCOME_DIRECTION_GROUNDING_CHANGE"
fi

echo "VALIDATOR_RELAXATION_JUSTIFIED=NO"
echo "FIDELITY_GUARD_REMOVAL_JUSTIFIED=NO"
echo "DOGFOOD_RETRY=NO"
echo "IMPLEMENTATION_PERFORMED=NO"

echo
echo "=== SAFETY ==="
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test -z "$(git diff --name-only)"
test -z "$(git diff --cached --name-only)"
echo "CODE_MUTATION=NONE"
echo "DATABASE_MUTATION=NONE"
echo "DOGFOOD_RETRY=NO"
echo "COMMIT_PERFORMED=NO"
echo "PUSH_PERFORMED=NO"
