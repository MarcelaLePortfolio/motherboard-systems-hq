#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INSPECT MATILDA COLLABORATION RUNTIME VALIDATION TESTS ==="

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short=8 HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY INSPECTION-ONLY SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/inspect-matilda-collaboration-runtime-validation-tests\.sh$|^ M scripts/inspect-matilda-collaboration-runtime-validation-tests\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "INSPECTION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== LIST OLLAMA / INVESTIGATION LIFECYCLE TESTS ==="
find scripts/utils -maxdepth 1 -type f \
  \( -name '*ollamaChat*test.ts' -o -name '*investigation*lifecycle*test.ts' \) \
  -print |
sort

echo
echo "=== LIST IEL / WORKFLOW LIFECYCLE TESTS ==="
find db server -type f \
  \( -name '*investigation*lifecycle*test.ts' -o -name '*lifecycle*retrieval*test.ts' -o -name '*lifecycle*transport*test.ts' \) \
  -print |
sort

echo
echo "=== SEARCH PRIOR LIFECYCLE TEST REFERENCES ==="
grep -RInE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'priorInvestigationLifecycle|prior investigation lifecycle|prior-investigation-lifecycle|scoped lifecycle retrieval|investigation lifecycle reconstruction|lifecycle transport' \
  scripts/utils db server 2>/dev/null |
head -n 1200 || true

echo
echo "=== INSPECTION COMPLETE ==="
echo "VALIDATION_TEST_FILENAME_INSPECTION_COMPLETE"
echo "PRODUCTION_RUNTIME_CHANGE=NONE"
echo "VALIDATION_SCRIPT_CHANGE=NONE"
echo "NEXT_ACTION=CLASSIFY_ACTUAL_MILESTONE_VALIDATION_TEST_SET"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/inspect-matilda-collaboration-runtime-validation-tests.sh
git diff --cached --check
git commit -m "Inspect milestone validation test filenames"
git push
