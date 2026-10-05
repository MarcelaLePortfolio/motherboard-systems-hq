#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="abe551656"
TARGET="scripts/utils/ollamaChat.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test -z "$(git status --porcelain)"

echo "=== OPERATION DIRECTION FIDELITY — INSPECTION ==="

echo
echo "=== CURRENT FIDELITY NORMALIZATION ==="
sed -n '941,1035p' "$TARGET"

echo
echo "=== OPERATION SEMANTIC MAPPING ==="
grep -n -B20 -A80 \
  'operationSemanticTerms' \
  "$TARGET"

echo
echo "=== DIRECTIONAL TERMS IN FIDELITY IMPLEMENTATION ==="
grep -nEi \
  'remove|restore|hide|show|delete|add|disable|enable|visibility|operationTerms|preservesOperation|preservesSubject' \
  "$TARGET" | head -240

echo
echo "=== FIDELITY TEST COVERAGE ==="
grep -RIn -B15 -A35 -E \
  'expectedOutcome|preservesOperation|Package Semantics fidelity|remove|restore' \
  scripts/utils \
  --include='*.test.ts' \
  --exclude='ollamaChat.expected-outcome-diagnostic-observability.test.ts' \
  | head -700 || true

echo
echo "=== CAPTURED FAILURE ==="
echo "REQUEST_OPERATION=remove"
echo "REQUEST_SUBJECT=packages_tab"
echo "MODEL_EXPECTED_OUTCOME=Canonical Package visibility restored"
echo "MODEL_OPERATION=restore"
echo "DIRECTION_CONTRADICTION=YES"

echo
echo "=== DECISION QUESTION ==="
echo "QUESTION=WHY_DID_EXISTING_OPERATION_FIDELITY_REACH_REJECTION_FOR_REMOVE_VS_RESTORE_AND_WHAT_EXACT_POLARITY_GAP_REMAINS"
echo "PURPOSE=IDENTIFY_EXACT_DIRECTIONAL_POLARITY_GAP_BEFORE_ANY_IMPLEMENTATION"
echo "DOGFOOD_RETRY=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "CONTRACT_RELAXATION_AUTHORIZED=NO"

echo
echo "=== SAFETY ==="
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test -z "$(git diff --name-only)"
test -z "$(git diff --cached --name-only)"
echo "CODE_MUTATION=NONE"
echo "DATABASE_MUTATION=NONE"
echo "COMMIT_PERFORMED=NO"
echo "PUSH_PERFORMED=NO"
