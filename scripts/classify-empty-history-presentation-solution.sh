#!/bin/bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="32118c841"

echo "=== EMPTY-HISTORY SUPPORT — PRESENTATION SOLUTION CLASSIFICATION ==="

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
git fetch origin "$BRANCH"

LOCAL_HEAD="$(git rev-parse HEAD)"
REMOTE_HEAD="$(git rev-parse "origin/$BRANCH")"

echo "LOCAL_HEAD=$LOCAL_HEAD"
echo "REMOTE_HEAD=$REMOTE_HEAD"

test "$LOCAL_HEAD" = "$REMOTE_HEAD"

echo
echo "=== 1. CURRENT EMPTY-HISTORY PRESENTATION ==="
nl -ba scripts/utils/ollamaChat.ts | sed -n '1138,1162p'
echo
nl -ba scripts/utils/ollamaChat.ts | sed -n '1318,1328p'
echo

echo "=== 2. SUCCESSFUL PRESENTATION-FIX PRECEDENT ==="
git show --format= 76be61326 -- scripts/utils/ollamaChat.ts
echo
git show --format= 2f8bc31ed -- scripts/utils/ollamaChat.ts
echo

echo "=== 3. CURRENT EMPTY-HISTORY TEST COVERAGE ==="
sed -n '130,205p' scripts/utils/ollamaChat.support-source-production.test.ts
echo

echo "=== 4. IDENTIFY CONDITIONAL PROMPT-COMPOSITION PRECEDENT ==="
git grep -n -B8 -A16 \
  -e 'length > 0' \
  -e 'length === 0' \
  -e '? \[' \
  HEAD -- scripts/utils/ollamaChat.ts | head -700 || true
echo

echo "=== 5. CLASSIFICATION ==="
echo "PARSER_DEFECT_EVIDENCED=NO"
echo "VALIDATOR_DEFECT_EVIDENCED=NO"
echo "VALIDATOR_WEAKENING_ALLOWED=NO"
echo "SCHEMA_BOUNDING_HYPOTHESIS=SET_ASIDE"
echo "SCHEMA_BOUNDING_FAILED_ATTEMPTS=2"
echo "SCHEMA_BOUNDING_ATTEMPT_3=NO"
echo "PROMPT_PRESENTATION_PRECEDENT=YES"
echo "CURRENT_EMPTY_HISTORY_PROMPT_CONTAINS_CONVERSATION_TURN_VOCABULARY=YES"
echo "DIFFERENT_SOLUTION_CLASS=INVOCATION_RELATIVE_PROMPT_PRESENTATION"
echo "PROPOSED_DIRECTION=WHEN_ALLOWED_CONVERSATION_SUPPORT_IDS_ARE_EMPTY_PRESENT_ONLY_THE_REQUIRED_EMPTY_ARRAY_CONTRACT_AND_OMIT_POSITIVE_CONVERSATION_TURN_CONSTRUCTION_INSTRUCTIONS"
echo "FAIL_CLOSED_VALIDATION_PRESERVED=YES"
echo "OUTPUT_SCHEMA_UNCHANGED=YES"
echo "PARSER_UNCHANGED=YES"
echo "AUTHORITY_MODEL_UNCHANGED=YES"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo

echo "=== 6. SAFETY ==="
test -z "$(git diff --cached --name-only)"
echo "CODE_MUTATION=NONE"
echo "DATABASE_MUTATION=NONE"
echo "COMMIT_PERFORMED=NO"
echo "PUSH_PERFORMED=NO"
