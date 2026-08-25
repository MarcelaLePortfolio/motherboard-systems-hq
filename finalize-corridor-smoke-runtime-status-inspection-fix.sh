#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== FINALIZE CORRIDOR-SMOKE RUNTIME STATUS INSPECTION FIX ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== VERIFY ONLY EXPECTED CLASSIFIER EDIT IS PENDING ==="
git diff -- classify-corridor-smoke-downstream-runtime-status.sh

if git diff --quiet -- classify-corridor-smoke-downstream-runtime-status.sh; then
  echo "ERROR=EXPECTED_CLASSIFIER_EDIT_NOT_PRESENT"
  exit 1
fi

UNEXPECTED="$(
  git status --short \
    | grep -vE 'classify-corridor-smoke-downstream-runtime-status\.sh$|finalize-corridor-smoke-runtime-status-inspection-fix\.sh$' \
    || true
)"

if [[ -n "$UNEXPECTED" ]]; then
  echo "ERROR=UNEXPECTED_WORKTREE_CHANGES"
  printf '%s\n' "$UNEXPECTED"
  exit 1
fi

echo
echo "=== FAILURE CLASSIFICATION ==="
echo "FAILED_HYPOTHESIS=NO"
echo "INSPECTION_HARNESS_REPAIR=VERIFIED"
echo "PRODUCTION_SOURCE_CHANGE=NO"
echo "DATABASE_CHANGE=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "=== COMMIT PENDING INSPECTION FIX ==="
git add classify-corridor-smoke-downstream-runtime-status.sh
git commit -m "Complete corridor smoke runtime status inspection fix"
git push

echo
echo "=== RERUN REPAIRED CLASSIFICATION ==="
./classify-corridor-smoke-downstream-runtime-status.sh

echo
echo "=== FINAL WORKTREE ==="
git status --short
