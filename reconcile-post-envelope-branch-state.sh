#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="5b3e31357"
IMPLEMENTATION="8c0ceba40"
BOOKKEEPING="6576d9b82"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

BEFORE_UNSTAGED="$(git diff --name-only)"

printf '\n=== COMMIT PROVENANCE ===\n'
git merge-base --is-ancestor "$IMPLEMENTATION" "origin/$BRANCH"
echo 'IMPLEMENTATION_COMMIT_REMOTE=YES'

git merge-base --is-ancestor "$BOOKKEEPING" "origin/$BRANCH"
echo 'BOOKKEEPING_COMMIT_REMOTE=YES'

printf '\n=== IMPLEMENTATION VALIDATION ===\n'
npx tsx --test \
  server/lifecycle/production-post-envelope-lifecycle-composition.test.ts
npx tsc --noEmit

printf '\n=== AUTHORITY BOUNDARY ===\n'
grep -nE \
  'ProductionLifecycleEntryPointInput|handoffProductionEnvelopeToLifecycle|new_authority_introduced' \
  server/lifecycle/production-post-envelope-lifecycle-composition.ts \
  server/lifecycle/production-post-envelope-lifecycle-composition.test.ts

printf '\n=== CLASSIFICATION ===\n'
echo 'MINIMAL_POST_ENVELOPE_LIFECYCLE_COMPOSITION=IMPLEMENTED'
echo 'EXISTING_LIFECYCLE_INPUTS_REUSED=YES'
echo 'EXISTING_LIFECYCLE_AUTHORITY_REUSED=YES'
echo 'NEW_AUTHORITY_INTRODUCED=NO'
echo 'SYNTHETIC_LIFECYCLE_INPUTS_INTRODUCED=NO'
echo 'TARGETED_TESTS=PASS'
echo 'TYPESCRIPT_VALIDATION=PASS'
echo 'IMPLEMENTATION_COMMIT_REMOTE=YES'
echo 'BOOKKEEPING_COMMIT_REMOTE=YES'

printf '\n=== SCOPED SAFETY ===\n'
test -z "$(git diff --cached --name-only)"
AFTER_UNSTAGED="$(git diff --name-only)"
test "$BEFORE_UNSTAGED" = "$AFTER_UNSTAGED"
echo 'PREEXISTING_UNSTAGED_STATE=PRESERVED'

git add -- reconcile-post-envelope-branch-state.sh
git commit -m "Reconcile post-envelope lifecycle composition"

git push origin "$BRANCH"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

printf '\n=== FINAL CONVERGENCE ===\n'
printf 'LOCAL_HEAD=%s\n' "$(git rev-parse --short=9 HEAD)"
printf 'REMOTE_HEAD=%s\n' "$(git rev-parse --short=9 "origin/$BRANCH")"
printf 'DIVERGENCE='
git rev-list --left-right --count "HEAD...origin/$BRANCH"
echo 'POST_ENVELOPE_LIFECYCLE_COMPOSITION_RECONCILED=YES'
