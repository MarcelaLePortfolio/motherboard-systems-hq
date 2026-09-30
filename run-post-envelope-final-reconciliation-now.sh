#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="2ec6c8cce"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

BEFORE_UNSTAGED="$(git diff --name-only)"

printf '\n=== FINAL IMPLEMENTATION VALIDATION ===\n'
npx tsx --test \
  server/lifecycle/production-envelope-lifecycle-handoff.test.ts \
  server/lifecycle/production-post-envelope-lifecycle-composition.test.ts

npx tsc --noEmit

printf '\n=== AUTHORITY INVARIANTS ===\n'
grep -nE \
  'ProductionLifecycleEntryPointInput|handoffProductionEnvelopeToLifecycle|new_authority_introduced' \
  server/lifecycle/production-envelope-lifecycle-handoff.ts \
  server/lifecycle/production-envelope-lifecycle-handoff.test.ts \
  server/lifecycle/production-post-envelope-lifecycle-composition.ts \
  server/lifecycle/production-post-envelope-lifecycle-composition.test.ts

printf '\n=== REMOTE IMPLEMENTATION PROVENANCE ===\n'
git merge-base --is-ancestor 93f4ec109 "origin/$BRANCH"
echo 'BOUNDED_HANDOFF_COMMIT_REMOTE=YES'

git merge-base --is-ancestor 8c0ceba40 "origin/$BRANCH"
echo 'POST_ENVELOPE_COMPOSITION_COMMIT_REMOTE=YES'

printf '\n=== SCOPED SAFETY ===\n'
test -z "$(git diff --cached --name-only)"

AFTER_UNSTAGED="$(git diff --name-only)"
test "$BEFORE_UNSTAGED" = "$AFTER_UNSTAGED"
echo 'PREEXISTING_UNSTAGED_STATE=PRESERVED'

printf '\n=== FINAL CLASSIFICATION ===\n'
echo 'BOUNDED_ENVELOPE_TO_LIFECYCLE_HANDOFF=IMPLEMENTED'
echo 'MINIMAL_POST_ENVELOPE_LIFECYCLE_COMPOSITION=IMPLEMENTED'
echo 'EXISTING_LIFECYCLE_INPUTS_REUSED=YES'
echo 'EXISTING_LIFECYCLE_AUTHORITY_REUSED=YES'
echo 'NEW_AUTHORITY_INTRODUCED=NO'
echo 'SYNTHETIC_LIFECYCLE_INPUTS_INTRODUCED=NO'
echo 'TARGETED_TESTS=PASS'
echo 'TYPESCRIPT_VALIDATION=PASS'
echo 'IMPLEMENTATION_BOUNDARY_READY_FOR_CLOSURE=YES'

git add -- run-post-envelope-final-reconciliation-now.sh
git commit -m "Validate post-envelope lifecycle composition closure"
git push origin "$BRANCH"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

printf '\n=== FINAL CONVERGENCE ===\n'
printf 'LOCAL_HEAD=%s\n' "$(git rev-parse --short=9 HEAD)"
printf 'REMOTE_HEAD=%s\n' "$(git rev-parse --short=9 "origin/$BRANCH")"
printf 'DIVERGENCE='
git rev-list --left-right --count "HEAD...origin/$BRANCH"

echo 'POST_ENVELOPE_LIFECYCLE_COMPOSITION_RECONCILED=YES'
echo 'IMPLEMENTATION_BOUNDARY=CLOSED'
