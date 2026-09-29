#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="867743cb0"
SOURCE="server/lifecycle/production-envelope-lifecycle-handoff.ts"
TEST="server/lifecycle/production-envelope-lifecycle-handoff.test.ts"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"

printf '\n=== HANDOFF FILES ===\n'
git ls-files --error-unmatch "$SOURCE"
git ls-files --error-unmatch "$TEST"

printf '\n=== TARGETED TEST ===\n'
npx tsx --test "$TEST"

printf '\n=== TYPECHECK ===\n'
npx tsc --noEmit

printf '\n=== RUNTIME CALLERS OF HANDOFF ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B20 -A60 \
  'handoffProductionEnvelopeToLifecycle|production-envelope-lifecycle-handoff' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== EXISTING ENVELOPE CREATION CALLERS ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B15 -A50 \
  'ENVELOPE_CREATED|createGovernanceEnvelope|consumeProductionEnvelope' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== CLASSIFICATION ===\n'
if grep -RqlE \
  --include='*.ts' --include='*.mjs' \
  'handoffProductionEnvelopeToLifecycle' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' >/dev/null 2>&1
then
  echo 'LIVE_RUNTIME_HANDOFF_CALLER=FOUND'
  echo 'NEXT_STEP=VALIDATE_END_TO_END_LIVE_TRANSITION'
else
  echo 'LIVE_RUNTIME_HANDOFF_CALLER=ABSENT'
  echo 'NEXT_STEP=WIRE_EXISTING_ENVELOPE_COMPLETION_SURFACE_TO_BOUNDED_HANDOFF'
fi

echo 'NEW_AUTHORITY_ALLOWED=NO'
echo 'SYNTHETIC_INPUTS_ALLOWED=NO'
echo 'IMPLEMENTATION_PERFORMED_BY_THIS_CHECK=NO'

printf '\n=== SAFETY ===\n'
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

printf 'LOCAL_HEAD=%s\n' "$(git rev-parse --short=9 HEAD)"
printf 'REMOTE_HEAD=%s\n' "$(git rev-parse --short=9 "origin/$BRANCH")"
printf 'DIVERGENCE='
git rev-list --left-right --count "HEAD...origin/$BRANCH"
