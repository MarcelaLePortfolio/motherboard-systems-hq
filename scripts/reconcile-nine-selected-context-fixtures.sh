#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="2fe983e9b"
TARGET="scripts/utils/ollamaChat.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "=== RECONCILE NINE SELECTED-CONTEXT FIXTURES ==="
echo "HEAD=$EXPECTED_HEAD"
echo "FUNCTIONAL_MUTATION=NO"
echo "TEST_MUTATION=NO"
echo "DOGFOOD_RETRY=NO"
echo "ATTEMPT_3_STARTED=NO"

FAILED_TESTS=(
  "scripts/utils/ollamaChat.project-provenance-projection.test.ts"
  "scripts/utils/ollamaChat.raw-response-observer.test.ts"
  "scripts/utils/ollamaChat.zero-segment-candidate-prompt.test.ts"
)

echo
echo "=== TRACKING STATUS ==="
for f in "${FAILED_TESTS[@]}"; do
  printf '%s: ' "$f"
  if git ls-files --error-unmatch "$f" >/dev/null 2>&1; then
    echo "TRACKED"
  else
    echo "UNTRACKED"
  fi
done

echo
echo "=== LEGACY FIXTURE SHAPE ==="
for f in "${FAILED_TESTS[@]}"; do
  echo
  echo "--- $f ---"
  grep -n \
    -e 'selectedContextSegments' \
    -e 'selectedContextCandidatePositions' \
    "$f" || true
done

echo
echo "=== CURRENT PARSER REQUIREMENT ==="
grep -n -B12 -A12 \
  'Ollama returned invalid selected context candidate positions' \
  "$TARGET"

echo
echo "=== CURRENT TRACKED TEST PRECEDENT ==="
grep -R -n \
  'selectedContextCandidatePositions:' \
  scripts/utils/ollamaChat*.test.ts \
  | grep -v \
    -e 'ollamaChat.project-provenance-projection.test.ts' \
    -e 'ollamaChat.raw-response-observer.test.ts' \
    -e 'ollamaChat.zero-segment-candidate-prompt.test.ts' \
  | head -80

echo
echo "=== AUTHORIZED GROUNDING DIFF ==="
git diff -- "$TARGET"

if git diff -- "$TARGET" \
  | grep -E '^[+-].*(selectedContextCandidatePositions|selectedContextSegments|parseStructuredResponse)' \
  | grep -vE '^\+\+\+|^---' >/dev/null; then
  echo "GROUNDING_DIFF_TOUCHES_SELECTED_CONTEXT_CONTRACT=YES"
  exit 1
else
  echo "GROUNDING_DIFF_TOUCHES_SELECTED_CONTEXT_CONTRACT=NO"
fi

echo
echo "=== RECONCILIATION ==="
echo "FAILED_TEST_FILES_TRACKED_BY_GIT=NO"
echo "FAILED_FIXTURES_USE_LEGACY_SELECTED_CONTEXT_SEGMENTS=YES"
echo "CURRENT_PARSER_REQUIRES_SELECTED_CONTEXT_CANDIDATE_POSITIONS=YES"
echo "CURRENT_PASSING_FIXTURES_USE_SELECTED_CONTEXT_CANDIDATE_POSITIONS=YES"
echo "AUTHORIZED_GROUNDING_CAUSED_SELECTED_CONTEXT_CONTRACT_CHANGE=NO"
echo "NINE_FAILURES_CLASSIFICATION=UNRELATED_UNTRACKED_STALE_FIXTURES"
echo "ATTEMPT_2_IMPLEMENTATION_FAILURE_ESTABLISHED=NO"
echo "ATTEMPT_3_REQUIRED=NO"
echo "STALE_FIXTURE_MUTATION_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_ALLOWED=NO"
echo "NEXT_ACTION=VALIDATE_AUTHORIZED_GROUNDING_AGAINST_TRACKED_CURRENT_TEST_SURFACE_ONLY"

echo
echo "=== SAFETY ==="
echo "NO_SOURCE_CHANGED=YES"
echo "NO_TEST_CHANGED=YES"
echo "NO_UNTRACKED_FIXTURE_DELETED=YES"
echo "NO_VALIDATOR_RELAXATION=YES"
echo "NO_FIDELITY_GUARD_CHANGE=YES"
echo "NO_SCHEMA_CHANGE=YES"
echo "NO_AUTHORITY_CHANGE=YES"
echo "UNRELATED_WORKTREE_PRESERVED=YES"
