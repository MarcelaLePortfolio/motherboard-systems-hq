#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="ef6ebe3bd"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git status --porcelain)"

printf '\n=== PRODUCTION LIFECYCLE ENTRY POINT ===\n'
sed -n '1,180p' server/lifecycle/production-lifecycle-entry-point.ts

printf '\n=== LIVE PRODUCTION CALLERS ===\n'
grep -RniE \
  --include='*.ts' --include='*.tsx' --include='*.mjs' \
  'production-lifecycle-entry-point|consumeProductionLifecycleEntryPoint' \
  server db routes client/src \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== CALL SITES ===\n'
grep -RniE \
  --include='*.ts' --include='*.tsx' --include='*.mjs' \
  -B15 -A40 \
  'consumeProductionLifecycleEntryPoint\(' \
  server db routes client/src \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== LIVE DELEGATION / ENVELOPE HANDOFF SURFACES ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B12 -A45 \
  'delegation|ENVELOPE_CREATED|department_handshake|lifecycle' \
  server routes \
  2>/dev/null || true

printf '\n=== CLASSIFICATION ===\n'

CALLERS="$(
  grep -RliE \
    --include='*.ts' --include='*.tsx' --include='*.mjs' \
    'consumeProductionLifecycleEntryPoint' \
    server db routes client/src \
    2>/dev/null \
    | grep -vE '\.test\.|\.spec\.|server/lifecycle/production-lifecycle-entry-point\.ts' \
    || true
)"

if [ -n "$CALLERS" ]; then
  echo 'PRODUCTION_LIFECYCLE_ENTRY_POINT=EXISTS'
  echo 'LIVE_TRIGGER_CANDIDATE=FOUND'
  printf '%s\n' "$CALLERS"
  echo 'NEXT_STEP=VERIFY_LIVE_TRIGGER_INPUTS_AND_ASSIGNMENT_TRANSITION'
else
  echo 'PRODUCTION_LIFECYCLE_ENTRY_POINT=EXISTS'
  echo 'LIVE_TRIGGER=ABSENT'
  echo 'CONFIRMED_GAP=LIVE_DELEGATION_FLOW_DOES_NOT_INVOKE_LIFECYCLE_ENTRY_POINT'
  echo 'NEXT_STEP=IMPLEMENT_SMALLEST_EXISTING_FLOW_TO_LIFECYCLE_HANDOFF'
fi

echo 'NEW_AUTHORITY_REQUIRED=NO'
echo 'IMPLEMENTATION_PERFORMED=NO'

printf '\n=== SAFETY ===\n'
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

printf 'LOCAL_HEAD=%s\n' "$(git rev-parse --short=9 HEAD)"
printf 'REMOTE_HEAD=%s\n' "$(git rev-parse --short=9 "origin/$BRANCH")"
printf 'DIVERGENCE='
git rev-list --left-right --count "HEAD...origin/$BRANCH"
