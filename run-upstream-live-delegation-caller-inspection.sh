#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="bab9540ca"
SCRIPT="inspect-upstream-live-delegation-caller.sh"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"
test -f "$SCRIPT"

BEFORE_UNSTAGED="$(git diff --name-only)"

printf '\n=== RUN UPSTREAM LIVE DELEGATION INSPECTION ===\n'
bash "$SCRIPT"

printf '\n=== SCOPED SAFETY ===\n'
test -z "$(git diff --cached --name-only)"
AFTER_UNSTAGED="$(git diff --name-only)"
test "$BEFORE_UNSTAGED" = "$AFTER_UNSTAGED"
echo 'PREEXISTING_UNSTAGED_STATE=PRESERVED'

printf '\n=== STATUS ===\n'
echo 'IMPLEMENTATION_PERFORMED=NO'
echo 'LIVE_TASK_SUBMISSION_PERFORMED=NO'
echo 'NEXT_STEP=CLASSIFY_EXACT_REGISTERED_LIVE_DELEGATION_ENTRY_POINT_FROM_OUTPUT'

git add -- run-upstream-live-delegation-caller-inspection.sh
git commit -m "Run upstream live delegation caller inspection"
git push origin "$BRANCH"
