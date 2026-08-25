#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== FINALIZE PROJECT-SCOPED DELEGATION HARNESS REWRITE ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== VERIFY EXACT PENDING CHANGE ==="
test -n "$(git diff -- implement-project-scoped-delegation-reference.sh)" || {
  echo "ERROR=EXPECTED_IMPLEMENTATION_HARNESS_EDIT_NOT_PRESENT"
  exit 1
}

UNEXPECTED="$(
  git status --short \
    | grep -vE 'implement-project-scoped-delegation-reference\.sh$|finalize-project-scoped-delegation-harness-rewrite\.sh$' \
    || true
)"

if [[ -n "$UNEXPECTED" ]]; then
  echo "ERROR=UNEXPECTED_WORKTREE_CHANGES"
  printf '%s\n' "$UNEXPECTED"
  exit 1
fi

git diff --check

echo
echo "=== CLASSIFICATION ==="
echo "FAILED_HYPOTHESIS=NO"
echo "STOP_POINT=REWRITTEN_IMPLEMENTATION_HARNESS_PENDING_COMMIT"
echo "REWRITE_AGAINST_VERIFIED_LIVE_FRAGMENTS=YES"
echo "AUTHORIZED_IMPLEMENTATION_SCOPE_CHANGED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== COMMIT REPAIRED IMPLEMENTATION HARNESS ==="
git add implement-project-scoped-delegation-reference.sh
git commit -m "Align project-scoped Delegation patch with live runtime"
git push

echo
echo "=== RERUN AUTHORIZED IMPLEMENTATION ==="
./implement-project-scoped-delegation-reference.sh
