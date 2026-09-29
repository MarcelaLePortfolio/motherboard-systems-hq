#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="300bb1841"
TARGET="server/routes/governance-envelope-route.ts"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git status --porcelain)"

printf '\n=== ENVELOPE ROUTE ===\n'
sed -n '1,420p' "$TARGET"

printf '\n=== EXISTING LIFECYCLE ENTRY CONTRACT ===\n'
sed -n '1,260p' server/lifecycle/production-lifecycle-entry-point.ts
sed -n '1,320p' server/lifecycle/production-lifecycle-consumer.ts

printf '\n=== EXISTING LIFECYCLE INPUT SOURCES ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B25 -A90 \
  'department_handshake|available_departments|available_actors' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== EXACT ENVELOPE ROUTE CAPABILITY ===\n'
if grep -qE \
  'department_handshake|available_departments|available_actors' \
  "$TARGET"
then
  echo 'ENVELOPE_ROUTE_HAS_EXISTING_LIFECYCLE_INPUTS=YES'
  echo 'NEXT_STEP=COMPOSE_EXISTING_INPUTS_INTO_EXISTING_LIFECYCLE_ENTRY_POINT'
else
  echo 'ENVELOPE_ROUTE_HAS_EXISTING_LIFECYCLE_INPUTS=NO'
  echo 'DO_NOT_WIRE_ENVELOPE_ROUTE_DIRECTLY=YES'
  echo 'NEXT_STEP=USE_NEAREST_EXISTING_SURFACE_THAT_ALREADY_POSSESSES_LIFECYCLE_INPUTS'
fi

echo 'AUTHORIZATION=BOUNDED_LIVE_ENVELOPE_TO_LIFECYCLE_HANDOFF'
echo 'NEW_AUTHORITY_ALLOWED=NO'
echo 'SYNTHETIC_LIFECYCLE_INPUTS_ALLOWED=NO'
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
