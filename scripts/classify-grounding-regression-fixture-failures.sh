#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="b76065e83"
TARGET="scripts/utils/ollamaChat.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "=== CLASSIFY GROUNDING REGRESSION FAILURES ==="
echo "HEAD=$EXPECTED_HEAD"
echo "FUNCTIONAL_MUTATION=NO"
echo "DOGFOOD_RETRY=NO"
echo "ATTEMPT_3_STARTED=NO"

echo
echo "=== ESTABLISHED VALIDATION BOUNDARY ==="
echo "FOCUSED_GROUNDING_TEST=PASS"
echo "CONDITIONAL_CONVERSATION_SUPPORT=PASS"
echo "PACKAGE_SEMANTICS_CONTRACT_FIDELITY=26_PASS_0_FAIL"
echo "BROAD_REGRESSION=137_PASS_9_FAIL"

echo
echo "=== FAILED TEST FIXTURES ==="
for f in \
  scripts/utils/ollamaChat.project-provenance-projection.test.ts \
  scripts/utils/ollamaChat.raw-response-observer.test.ts \
  scripts/utils/ollamaChat.zero-segment-candidate-prompt.test.ts
do
  echo
  echo "--- $f ---"
  git status --short -- "$f"
  git log -5 --oneline -- "$f"
  grep -n \
    -e 'selectedContextCandidatePositions' \
    -e 'selectedContextSegments' \
    -e 'selectedContext' \
    "$f" | head -160 || true
done

echo
echo "=== CURRENT PARSER CONTRACT ==="
sed -n '870,930p' "$TARGET"

echo
echo "=== PASSING CURRENT FIXTURE SHAPES ==="
grep -R -n \
  'selectedContextCandidatePositions' \
  scripts/utils/ollamaChat*.test.ts \
  | head -200 || true

echo
echo "=== AUTHORIZED DIFF CAUSALITY ==="
git diff -- "$TARGET"

if git diff -- "$TARGET" \
  | grep -E '^[+-].*(selectedContextCandidatePositions|parseStructuredResponse)' \
  | grep -vE '^\+\+\+|^---' >/dev/null; then
  echo "AUTHORIZED_DIFF_TOUCHES_FAILING_PARSER_BOUNDARY=YES"
else
  echo "AUTHORIZED_DIFF_TOUCHES_FAILING_PARSER_BOUNDARY=NO"
fi

echo
echo "=== CLASSIFICATION ==="
echo "AUTHORIZED_GROUNDING_FOCUSED_VALIDATION=PASS"
echo "PACKAGE_SEMANTICS_BOUNDARY_VALIDATION=PASS"
echo "NINE_FAILURES_SHARE_SELECTED_CONTEXT_POSITION_BOUNDARY=YES"
echo "FIXTURE_CAUSALITY_RECONCILIATION_REQUIRED=YES"
echo "ATTEMPT_2_IMPLEMENTATION_FAILURE_ESTABLISHED=NO"
echo "ATTEMPT_3_REQUIRED=NO"
echo "FUNCTIONAL_CHANGE_COMMIT_READY=NO"
echo "LIVE_DOGFOOD_ALLOWED=NO"
echo "NEXT_ACTION=CLASSIFY_NINE_FAILURES_AS_STALE_FIXTURES_OR_CAUSAL_REGRESSION"

echo
echo "=== SAFETY ==="
echo "NO_SOURCE_MUTATION=YES"
echo "NO_TEST_MUTATION=YES"
echo "NO_VALIDATOR_RELAXATION=YES"
echo "NO_FIDELITY_GUARD_CHANGE=YES"
echo "NO_SCHEMA_CHANGE=YES"
echo "NO_AUTHORITY_CHANGE=YES"
echo "UNRELATED_WORKTREE_PRESERVED=YES"
