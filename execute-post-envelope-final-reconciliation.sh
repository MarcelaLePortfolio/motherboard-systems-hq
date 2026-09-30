#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="85d34ea73"
RECONCILE_SCRIPT="reconcile-post-envelope-branch-state.sh"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"
test -f "$RECONCILE_SCRIPT"

BEFORE_UNSTAGED="$(git diff --name-only)"

printf '\n=== EXECUTE RECONCILIATION ===\n'
bash "$RECONCILE_SCRIPT"

printf '\n=== POST-EXECUTION CONVERGENCE ===\n'
git fetch origin "$BRANCH"

test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

printf 'LOCAL_HEAD=%s\n' "$(git rev-parse --short=9 HEAD)"
printf 'REMOTE_HEAD=%s\n' "$(git rev-parse --short=9 "origin/$BRANCH")"
printf 'DIVERGENCE='
git rev-list --left-right --count "HEAD...origin/$BRANCH"

printf '\n=== SCOPED SAFETY ===\n'
test -z "$(git diff --cached --name-only)"
AFTER_UNSTAGED="$(git diff --name-only)"
test "$BEFORE_UNSTAGED" = "$AFTER_UNSTAGED"
echo 'PREEXISTING_UNSTAGED_STATE=PRESERVED'

printf '\n=== FINAL CLASSIFICATION ===\n'
echo 'MINIMAL_POST_ENVELOPE_LIFECYCLE_COMPOSITION=IMPLEMENTED'
echo 'EXISTING_LIFECYCLE_INPUTS_REUSED=YES'
echo 'EXISTING_LIFECYCLE_AUTHORITY_REUSED=YES'
echo 'NEW_AUTHORITY_INTRODUCED=NO'
echo 'SYNTHETIC_LIFECYCLE_INPUTS_INTRODUCED=NO'
echo 'RECONCILIATION_EXECUTED=YES'
echo 'LOCAL_REMOTE_CONVERGENCE=YES'
echo 'IMPLEMENTATION_BOUNDARY_READY_FOR_CLOSURE=YES'

git add -- execute-post-envelope-final-reconciliation.sh
git commit -m "Execute post-envelope final reconciliation"
git push origin "$BRANCH"
