#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="f006624f4"
TARGET="scripts/utils/ollamaChat.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test -z "$(git status --porcelain)"

echo "=== PACKAGE SEMANTICS DIRECTION GROUNDING — DECISIVE CLASSIFICATION ==="

echo
echo "=== CURRENT PROMPT CONTRACT ==="
sed -n '1338,1368p' "$TARGET"

echo
echo "=== EXACT DIRECTION LANGUAGE ==="
grep -nEi \
  'preserve.*(operation|direction)|operation.*direction|requested.*operation|opposite|invert' \
  "$TARGET" || true

echo
echo "=== CAPTURED LIVE CONTRADICTION ==="
echo "CURRENT_REQUEST_OPERATION=remove"
echo "CURRENT_REQUEST_SUBJECT=packages tab"
echo "CURRENT_REQUEST_PRESERVATION_BOUNDARY=underlying package runtime functionality and authority"
echo "MODEL_AUTHORED_EXPECTEDOUTCOME=Canonical Package visibility restored"
echo "MODEL_DIRECTION=restore_visibility"
echo "REQUEST_DIRECTION=remove_visibility"
echo "DIRECTION_MATCH=NO"

echo
echo "=== DETERMINE NEXT SOLUTION CLASS ==="
if grep -qEi \
  'preserve.*(operation|direction)|operation.*direction|requested.*operation|opposite|invert' \
  "$TARGET"; then
  echo "EXPLICIT_OPERATION_DIRECTION_CONTRACT=YES"
  echo "PROMPT_GROUNDING_GAP=NO"
  echo "MODEL_VIOLATED_EXISTING_EXPLICIT_CONTRACT=YES"
  echo "NARROW_PROMPT_WORDING_FIX_JUSTIFIED=NO"
  echo "NEXT_SOLUTION_CLASS=DETERMINISTIC_OPERATION_DIRECTION_FIDELITY"
  echo "NEXT_ACTION=INSPECT_EXISTING_FIDELITY_GUARD_FOR_DIRECTIONAL_ANTONYM_OR_OPERATION_POLARITY_GAP"
else
  echo "EXPLICIT_OPERATION_DIRECTION_CONTRACT=NO"
  echo "PROMPT_GROUNDING_GAP=YES"
  echo "MODEL_VIOLATED_EXISTING_EXPLICIT_CONTRACT=NO"
  echo "NARROW_PROMPT_WORDING_FIX_JUSTIFIED=YES"
  echo "NEXT_SOLUTION_CLASS=EXPLICIT_EXPECTEDOUTCOME_OPERATION_DIRECTION_GROUNDING"
  echo "NEXT_ACTION=REQUEST_AUTHORIZATION_FOR_NARROW_PROMPT_GROUNDING_IMPLEMENTATION"
fi

echo
echo "=== PRESERVED BOUNDARIES ==="
echo "FIDELITY_GUARD_REJECTION_CORRECT=YES"
echo "VALIDATOR_RELAXATION_JUSTIFIED=NO"
echo "FIDELITY_GUARD_REMOVAL_JUSTIFIED=NO"
echo "OUTPUT_SCHEMA_CHANGE_JUSTIFIED=NO"
echo "PARSER_CHANGE_JUSTIFIED=NO"
echo "AUTHORITY_MODEL_CHANGE_JUSTIFIED=NO"
echo "DOGFOOD_RETRY=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "=== SAFETY ==="
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test -z "$(git diff --name-only)"
test -z "$(git diff --cached --name-only)"
echo "CODE_MUTATION=NONE"
echo "DATABASE_MUTATION=NONE"
echo "COMMIT_PERFORMED=NO"
echo "PUSH_PERFORMED=NO"
