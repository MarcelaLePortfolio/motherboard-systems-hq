#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="e5d5ed891"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"

printf '\n=== NON-TEST LIFECYCLE TRANSITION CALLERS ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  'completeGovernanceLifecycleAssignmentTransition|composeGovernanceLifecycleAssignmentTransition' \
  db server routes \
  2>/dev/null \
  | grep -vE '\.test\.' || true

printf '\n=== PRODUCTION LIFECYCLE / INTAKE / ASSIGNMENT SURFACES ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B15 -A50 \
  'consumeProductionLifecycleEntryPoint|governance/lifecycle|operational.*intake|department_handshake|assignment_boundary' \
  server db routes \
  2>/dev/null || true

printf '\n=== CLASSIFICATION ===\n'
CALLERS="$(
  grep -RniE \
    --include='*.ts' --include='*.mjs' \
    'completeGovernanceLifecycleAssignmentTransition|composeGovernanceLifecycleAssignmentTransition' \
    db server routes \
    2>/dev/null \
    | grep -vE '\.test\.|db/governance-lifecycle-(integration|composition)\.ts' \
    || true
)"

if [ -n "$CALLERS" ]; then
  echo 'PRODUCTION_LIFECYCLE_CALLER=FOUND'
  printf '%s\n' "$CALLERS"
  echo 'NEXT_STEP=INSPECT_FOUND_CALLER_AND_VERIFY_LIVE_TRIGGER'
else
  echo 'PRODUCTION_LIFECYCLE_CALLER=ABSENT'
  echo 'LIKELY_GAP=NO_PRODUCTION_HANDOFF_INTO_EXISTING_ASSIGNMENT_TRANSITION'
  echo 'NEXT_STEP=DEFINE_SMALLEST_GOVERNED_HANDOFF_WITHOUT_CREATING_NEW_AUTHORITY'
fi

echo 'IMPLEMENTATION_PERFORMED=NO'
echo 'COMMIT_PERFORMED=NO'
echo 'PUSH_PERFORMED=NO'

printf '\n=== SAFETY ===\n'
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

printf 'LOCAL_HEAD=%s\n' "$(git rev-parse --short=9 HEAD)"
printf 'REMOTE_HEAD=%s\n' "$(git rev-parse --short=9 "origin/$BRANCH")"
printf 'DIVERGENCE='
git rev-list --left-right --count "HEAD...origin/$BRANCH"
