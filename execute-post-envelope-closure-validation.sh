#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="177e4d3c9"
RUNNER="run-post-envelope-final-reconciliation-now.sh"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"
test -f "$RUNNER"

BEFORE_UNSTAGED="$(git diff --name-only)"

printf '\n=== EXECUTE CLOSURE VALIDATION ===\n'
bash "$RUNNER"

printf '\n=== VERIFY FINAL CONVERGENCE ===\n'
git fetch origin "$BRANCH"

test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

printf 'LOCAL_HEAD=%s\n' "$(git rev-parse --short=9 HEAD)"
printf 'REMOTE_HEAD=%s\n' "$(git rev-parse --short=9 "origin/$BRANCH")"
printf 'DIVERGENCE='
git rev-list --left-right --count "HEAD...origin/$BRANCH"

printf '\n=== VERIFY SCOPED SAFETY ===\n'
test -z "$(git diff --cached --name-only)"

AFTER_UNSTAGED="$(git diff --name-only)"
test "$BEFORE_UNSTAGED" = "$AFTER_UNSTAGED"
echo 'PREEXISTING_UNSTAGED_STATE=PRESERVED'

printf '\n=== CLOSURE ===\n'
echo 'POST_ENVELOPE_LIFECYCLE_COMPOSITION_VALIDATED=YES'
echo 'LOCAL_REMOTE_CONVERGENCE=YES'
echo 'NEW_AUTHORITY_INTRODUCED=NO'
echo 'IMPLEMENTATION_BOUNDARY=CLOSED'
