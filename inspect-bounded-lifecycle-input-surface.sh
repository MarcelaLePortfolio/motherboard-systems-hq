#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="938dc7574"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git status --porcelain)"

printf '\n=== ENVELOPE ROUTE LIFECYCLE INPUTS ===\n'
grep -nE \
  'department_handshake|available_departments|available_actors|ENVELOPE_CREATED' \
  server/routes/governance-envelope-route.ts || true

printf '\n=== NEAREST NON-TEST EXISTING INPUT SURFACES ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B20 -A70 \
  'department_handshake|available_departments|available_actors' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== LIFECYCLE ROUTE REQUEST CONTRACT ===\n'
sed -n '60,240p' server/routes/governance-lifecycle-route.ts

printf '\n=== LIFECYCLE CONSUMER INPUT CONTRACT ===\n'
sed -n '1,260p' server/lifecycle/production-lifecycle-consumer.ts

printf '\n=== LIFECYCLE ENTRY INPUT CONTRACT ===\n'
sed -n '1,220p' server/lifecycle/production-lifecycle-entry-point.ts

printf '\n=== CLASSIFICATION ===\n'
if grep -qE \
  'department_handshake|available_departments|available_actors' \
  server/routes/governance-envelope-route.ts
then
  echo 'ENVELOPE_ROUTE_HAS_EXISTING_LIFECYCLE_INPUTS=YES'
  echo 'NEXT_STEP=IMPLEMENT_BOUNDED_COMPOSITION_IN_ENVELOPE_FLOW'
else
  echo 'ENVELOPE_ROUTE_HAS_EXISTING_LIFECYCLE_INPUTS=NO'
  echo 'DIRECT_ENVELOPE_ROUTE_WIRING=REJECTED'
  echo 'NEXT_STEP=IDENTIFY_EXISTING_COMPOSITION_SURFACE_WITH_REQUIRED_INPUTS'
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
