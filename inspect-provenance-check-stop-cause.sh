#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="eb6893dfa"

git fetch origin "$BRANCH"

printf '\n=== FAILED PRECONDITION REPLAY ===\n'

if test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"; then
  echo 'BRANCH_CHECK=PASS'
else
  echo 'BRANCH_CHECK=FAIL'
fi

if test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"; then
  echo 'LOCAL_HEAD_CHECK=PASS'
else
  echo 'LOCAL_HEAD_CHECK=FAIL'
fi

if test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"; then
  echo 'REMOTE_HEAD_CHECK=PASS'
else
  echo 'REMOTE_HEAD_CHECK=FAIL'
fi

if test -z "$(git diff --cached --name-only)"; then
  echo 'STAGED_STATE_CHECK=PASS'
else
  echo 'STAGED_STATE_CHECK=FAIL'
fi

if test -z "$(git diff --name-only)"; then
  echo 'UNSTAGED_STATE_CHECK=PASS'
else
  echo 'UNSTAGED_STATE_CHECK=FAIL'
fi

printf '\n=== UNSTAGED PATHS ===\n'
git diff --name-only

printf '\n=== VERIFY SCRIPT STATE ===\n'
git status --short -- verify-runtime-lifecycle-provenance-now.sh

printf '\n=== CLASSIFICATION ===\n'
echo 'KNOWN=PREVIOUS_RUN_STOPPED_BEFORE_PROVENANCE_CLASSIFICATION'
echo 'KNOWN=LOCAL_AND_REMOTE_WERE_CONVERGED_BEFORE_STOP'
echo 'KNOWN=UNRELATED_UNSTAGED_WORK_PREEXISTED'
echo 'TARGET=IDENTIFY_EXACT_FAILED_GUARD'
echo 'IMPLEMENTATION_PERFORMED=NO'

printf '\n=== SAFETY ===\n'
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

git add -- inspect-provenance-check-stop-cause.sh
git commit -m "Inspect provenance check stop cause"
git push origin "$BRANCH"
