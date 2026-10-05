#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="d77975448"
TARGET="scripts/utils/ollamaChat.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "=== EXPECTEDOUTCOME MISMATCH — ROOT-CAUSE CLASSIFICATION ==="

echo
echo "=== CAPTURED EVIDENCE ==="
echo "CURRENT_REQUEST=remove the 'packages' tab from the sidebar while preserving all underlying package runtime functionality and authority"
echo "MODEL_AUTHORED_EXPECTEDOUTCOME=Canonical Package visibility restored"
echo
echo "REQUESTED_DIRECTION=REMOVE_PACKAGES_TAB_VISIBILITY"
echo "MODEL_DIRECTION=RESTORE_CANONICAL_PACKAGE_VISIBILITY"
echo "SEMANTIC_DIRECTION_CONTRADICTION=YES"

echo
echo "=== CURRENT FIDELITY LOGIC ==="
sed -n '941,1035p' "$TARGET"

echo
echo "=== PACKAGE SEMANTICS PROMPT CONSTRUCTION ==="
grep -n -B30 -A60 -E \
  'expectedOutcome|Package Semantics|packageSemantics' \
  "$TARGET" | head -900

echo
echo "=== EXPECTEDOUTCOME TEST CONTRACTS ==="
grep -RIn -B20 -A35 -E \
  'expectedOutcome|Canonical Package visibility restored' \
  scripts/utils \
  --include='*.test.ts' | head -1200 || true

echo
echo "=== RELEVANT LINEAGE ==="
git log --oneline -30 -S'expectedOutcome' -- \
  "$TARGET" \
  scripts/utils/'*.test.ts'

echo
echo "=== CLASSIFICATION ==="
echo "EMPTY_HISTORY_PROVENANCE_FAILURE=NO"
echo "CONDITIONAL_CONVERSATION_PROMPT_FAILURE=NO"
echo "EXPECTEDOUTCOME_VALUE_CAPTURED=YES"
echo "MODEL_EXPECTEDOUTCOME_PRESERVES_REQUESTED_OPERATION=NO"
echo "MODEL_EXPECTEDOUTCOME_PRESERVES_REQUESTED_DIRECTION=NO"
echo "FIDELITY_GUARD_REJECTION=JUSTIFIED_BY_CAPTURED_VALUE"
echo "VALIDATOR_RELAXATION_JUSTIFIED=NO"
echo "FAILURE_ORIGIN=UPSTREAM_PACKAGE_SEMANTICS_GENERATION_OR_PROMPT_GROUNDING"
echo "DOGFOOD_RETRY=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "NEXT_DECISION=IDENTIFY_WHY_PACKAGE_SEMANTICS_GENERATION_INVERTED_REMOVE_INTO_RESTORE_BEFORE_PROPOSING_FIX"

echo
echo "=== SAFETY ==="
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
echo "CODE_MUTATION=NONE"
echo "DATABASE_MUTATION=NONE"
echo "DOGFOOD_RETRY=NO"
echo "COMMIT_PERFORMED=NO"
echo "PUSH_PERFORMED=NO"
