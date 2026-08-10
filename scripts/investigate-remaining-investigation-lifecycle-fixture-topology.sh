#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INVESTIGATE REMAINING INVESTIGATION LIFECYCLE FIXTURE TOPOLOGY ==="

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY EXPECTED IN-PROGRESS SURFACE ==="
unexpected="$(
  git status --porcelain |
  sed -E 's/^.. //' |
  grep -vE '^scripts/guard-ollama-response-contract\.sh$|^scripts/utils/ollamaChat\.ts$|^scripts/utils/ollamaChat.*\.test\.ts$|^scripts/repair-investigation-lifecycle-regression-fixtures\.sh$|^scripts/complete-investigation-lifecycle-regression-fixture-repair\.sh$|^scripts/finalize-investigation-lifecycle-regression-reconciliation\.sh$|^scripts/investigate-remaining-investigation-lifecycle-fixture-topology\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected files exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "EXPECTED_IN_PROGRESS_SURFACE_CONFIRMED"

echo
echo "=== SELECTED-CONTEXT OBSERVER FULL TEST STRUCTURE ==="
sed -n '1,280p' \
  scripts/utils/ollamaChat.selected-context-observer.test.ts

echo
echo "=== SELECTED-CONTEXT MOCK RESPONSE CONSTRUCTORS ==="
grep -n -A24 -B8 \
  -E 'globalThis\.fetch|JSON\.stringify|response:|investigationLifecycle' \
  scripts/utils/ollamaChat.selected-context-observer.test.ts || true

echo
echo "=== SELECTED-CONTEXT COUNTS ==="
echo "TEST_COUNT=$(
  grep -cE '^test\(' \
    scripts/utils/ollamaChat.selected-context-observer.test.ts ||
  true
)"
echo "JSON_STRINGIFY_COUNT=$(
  grep -c 'JSON.stringify' \
    scripts/utils/ollamaChat.selected-context-observer.test.ts ||
  true
)"
echo "NULL_LIFECYCLE_COUNT=$(
  grep -c 'investigationLifecycle: null' \
    scripts/utils/ollamaChat.selected-context-observer.test.ts ||
  true
)"

echo
echo "=== VALIDATION-SEED FULL TEST STRUCTURE ==="
sed -n '1,240p' \
  scripts/utils/ollamaChat.validation-seed.test.ts

echo
echo "=== VALIDATION-SEED MOCK RESPONSE CONSTRUCTORS ==="
grep -n -A24 -B8 \
  -E 'globalThis\.fetch|JSON\.stringify|response:|investigationLifecycle' \
  scripts/utils/ollamaChat.validation-seed.test.ts || true

echo
echo "=== VALIDATION-SEED COUNTS ==="
echo "TEST_COUNT=$(
  grep -cE '^test\(' \
    scripts/utils/ollamaChat.validation-seed.test.ts ||
  true
)"
echo "JSON_STRINGIFY_COUNT=$(
  grep -c 'JSON.stringify' \
    scripts/utils/ollamaChat.validation-seed.test.ts ||
  true
)"
echo "NULL_LIFECYCLE_COUNT=$(
  grep -c 'investigationLifecycle: null' \
    scripts/utils/ollamaChat.validation-seed.test.ts ||
  true
)"

echo
echo "=== EXPLANATION STATUS EXPECTATION AFTER REPAIR ==="
sed -n '1,150p' \
  scripts/utils/ollamaChat.explanation-status.test.ts

echo
echo "=== RUN ONLY THE THREE PREVIOUSLY FAILING FILES ==="
set +e
npx tsx --test \
  scripts/utils/ollamaChat.explanation-status.test.ts \
  scripts/utils/ollamaChat.selected-context-observer.test.ts \
  scripts/utils/ollamaChat.validation-seed.test.ts
target_exit=$?
set -e

echo
echo "TARGETED_TEST_EXIT_CODE=$target_exit"

echo
echo "=== VERIFY PRODUCTION RUNTIME HAS NOT CHANGED DURING INVESTIGATION ==="
if ! git diff --quiet -- server/matilda-chat-workflow.ts; then
  echo "STOP: production workflow changed."
  git diff -- server/matilda-chat-workflow.ts
  exit 2
fi

echo "PRODUCTION_WORKFLOW_UNCHANGED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "INVESTIGATION_LIFECYCLE_FIXTURE_TOPOLOGY_COLLECTED"
echo "NO_ADDITIONAL_FIX_APPLIED"
echo "NEXT_ACTION=CLASSIFY_REMAINING_FIXTURE_RECONCILIATION_FROM_EXACT_TEST_TOPOLOGY"

git add scripts/investigate-remaining-investigation-lifecycle-fixture-topology.sh
git diff --cached --check
git commit -m "Investigate remaining Investigation Lifecycle fixture topology"
git push
