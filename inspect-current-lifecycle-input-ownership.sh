#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="e6742df8a"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git status --porcelain)"

printf '\n=== ENVELOPE ROUTE INPUT OWNERSHIP ===\n'
grep -nE \
  'department_handshake|available_departments|available_actors|ENVELOPE_CREATED' \
  server/routes/governance-envelope-route.ts || true

printf '\n=== EXISTING NON-TEST LIFECYCLE INPUT OWNERS ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B12 -A45 \
  'department_handshake|available_departments|available_actors' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== LIFECYCLE ROUTE CONTRACT ===\n'
sed -n '1,280p' server/routes/governance-lifecycle-route.ts

printf '\n=== PRODUCTION LIFECYCLE CONSUMER CONTRACT ===\n'
sed -n '1,320p' server/lifecycle/production-lifecycle-consumer.ts

printf '\n=== CLASSIFICATION ===\n'
if grep -qE \
  'department_handshake|available_departments|available_actors' \
  server/routes/governance-envelope-route.ts
then
  echo 'ENVELOPE_ROUTE_HAS_EXISTING_LIFECYCLE_INPUTS=YES'
  echo 'NEXT_STEP=IMPLEMENT_AUTHORIZED_BOUNDED_HANDOFF_IN_ENVELOPE_FLOW'
else
  echo 'ENVELOPE_ROUTE_HAS_EXISTING_LIFECYCLE_INPUTS=NO'
  echo 'DIRECT_ENVELOPE_ROUTE_WIRING=REJECTED'
  echo 'NEXT_STEP=IMPLEMENT_AT_EXISTING_INPUT_OWNING_COMPOSITION_SURFACE_ONLY'
fi

echo 'AUTHORIZATION=ACTIVE'
echo 'NEW_AUTHORITY_ALLOWED=NO'
echo 'SYNTHETIC_INPUTS_ALLOWED=NO'
echo 'IMPLEMENTATION_PERFORMED=NO'
echo 'COMMIT_PERFORMED=NO'
echo 'PUSH_PERFORMED=NO'

printf '\n=== SAFETY ===\n'
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"
test -z "$(git diff --name-only)"

printf 'LOCAL_HEAD=%s\n' "$(git rev-parse --short=9 HEAD)"
printf 'REMOTE_HEAD=%s\n' "$(git rev-parse --short=9 "origin/$BRANCH")"
printf 'DIVERGENCE='
git rev-list --left-right --count "HEAD...origin/$BRANCH"
