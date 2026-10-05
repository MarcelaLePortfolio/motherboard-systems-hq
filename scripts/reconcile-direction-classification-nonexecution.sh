#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="6d538f809"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "=== DIRECTION CLASSIFICATION RECONCILIATION ==="
echo "CLASSIFICATION_SCRIPT_COMMIT_NOT_CREATED=YES"
echo "REASON=PREEXISTING_UNRELATED_DIRTY_WORKTREE_PREVENTED_CLEAN_STATE_PRECONDITION"
echo "REMOTE_HEAD_UNCHANGED=YES"
echo "CURRENT_HEAD=$EXPECTED_HEAD"

echo
echo "=== IMPORTANT EVIDENCE BOUNDARY ==="
echo "CLASSIFICATION_OUTPUT_NOT_OBSERVED=YES"
echo "DO_NOT_TREAT_SCRIPT_DECLARATIONS_AS_EXECUTED_EVIDENCE=YES"
echo "DO_NOT_INFER_OPERATION_MAPPING_RESULT=YES"
echo "DOGFOOD_RETRY=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "=== PRESERVE UNRELATED WORK ==="
git status --short

echo
echo "=== TARGETED READ-ONLY FIDELITY INSPECTION ==="
sed -n '930,1045p' scripts/utils/ollamaChat.ts

echo
echo "=== OPERATION / DIRECTION TERMS ==="
grep -nEi \
  'remove|restore|hide|show|delete|add|disable|enable|visibility|operationSemanticTerms|preservesOperation|preservesSubject' \
  scripts/utils/ollamaChat.ts | head -300 || true

echo
echo "=== RELEVANT TEST COVERAGE ==="
grep -RIn -B12 -A30 -E \
  'expectedOutcome|Package Semantics fidelity|preservesOperation|remove|restore' \
  scripts/utils \
  --include='*.test.ts' \
  | head -700 || true

echo
echo "=== SAFETY ==="
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
echo "TARGET_CODE_MUTATION=NONE"
echo "DATABASE_MUTATION=NONE"
echo "UNRELATED_WORKTREE_PRESERVED=YES"
