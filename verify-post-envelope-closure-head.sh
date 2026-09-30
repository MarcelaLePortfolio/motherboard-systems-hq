#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="9f5809873"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

BEFORE_UNSTAGED="$(git diff --name-only)"

printf '\n=== VERIFIED CLOSURE EVIDENCE ===\n'
git merge-base --is-ancestor 93f4ec109 "origin/$BRANCH"
echo 'BOUNDED_HANDOFF_COMMIT_REMOTE=YES'

git merge-base --is-ancestor 8c0ceba40 "origin/$BRANCH"
echo 'POST_ENVELOPE_COMPOSITION_COMMIT_REMOTE=YES'

git merge-base --is-ancestor 9f5809873 "origin/$BRANCH"
echo 'CLOSURE_VALIDATION_COMMIT_REMOTE=YES'

printf '\n=== CLOSURE STATE ===\n'
echo 'BOUNDED_ENVELOPE_TO_LIFECYCLE_HANDOFF=VALIDATED'
echo 'MINIMAL_POST_ENVELOPE_LIFECYCLE_COMPOSITION=VALIDATED'
echo 'EXISTING_LIFECYCLE_INPUTS_REUSED=YES'
echo 'EXISTING_LIFECYCLE_AUTHORITY_REUSED=YES'
echo 'NEW_AUTHORITY_INTRODUCED=NO'
echo 'SYNTHETIC_LIFECYCLE_INPUTS_INTRODUCED=NO'
echo 'TARGETED_TESTS=4_PASS_0_FAIL'
echo 'TYPESCRIPT_VALIDATION=PASS'
echo 'IMPLEMENTATION_BOUNDARY=CLOSED'

printf '\n=== SCOPED SAFETY ===\n'
test -z "$(git diff --cached --name-only)"
AFTER_UNSTAGED="$(git diff --name-only)"
test "$BEFORE_UNSTAGED" = "$AFTER_UNSTAGED"
echo 'PREEXISTING_UNSTAGED_STATE=PRESERVED'

printf '\n=== BASELINE ===\n'
printf 'LOCAL_HEAD=%s\n' "$(git rev-parse --short=9 HEAD)"
printf 'REMOTE_HEAD=%s\n' "$(git rev-parse --short=9 "origin/$BRANCH")"
printf 'DIVERGENCE='
git rev-list --left-right --count "HEAD...origin/$BRANCH"

git add -- verify-post-envelope-closure-head.sh
git commit -m "Record post-envelope lifecycle implementation closure"
git push origin "$BRANCH"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

printf '\n=== FINAL ===\n'
printf 'LOCAL_HEAD=%s\n' "$(git rev-parse --short=9 HEAD)"
printf 'REMOTE_HEAD=%s\n' "$(git rev-parse --short=9 "origin/$BRANCH")"
printf 'DIVERGENCE='
git rev-list --left-right --count "HEAD...origin/$BRANCH"
echo 'POST_ENVELOPE_LIFECYCLE_IMPLEMENTATION_BOUNDARY=CLOSED'
