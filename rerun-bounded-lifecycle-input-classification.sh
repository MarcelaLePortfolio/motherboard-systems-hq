#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="0bb68eae3"
TARGET="server/routes/governance-envelope-route.ts"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git status --porcelain)"

printf '\n=== ENVELOPE ROUTE LIFECYCLE INPUTS ===\n'
grep -nE \
  'department_handshake|available_departments|available_actors|ENVELOPE_CREATED' \
  "$TARGET" || true

printf '\n=== NEAREST EXISTING INPUT SOURCES ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B15 -A45 \
  'department_handshake|available_departments|available_actors' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== CLASSIFICATION ===\n'
if grep -qE \
  'department_handshake|available_departments|available_actors' \
  "$TARGET"
then
  echo 'ENVELOPE_ROUTE_HAS_EXISTING_LIFECYCLE_INPUTS=YES'
  echo 'NEXT_STEP=COMPOSE_EXISTING_INPUTS_INTO_EXISTING_LIFECYCLE_ENTRY_POINT'
else
  echo 'ENVELOPE_ROUTE_HAS_EXISTING_LIFECYCLE_INPUTS=NO'
  echo 'DO_NOT_WIRE_ENVELOPE_ROUTE_DIRECTLY=YES'
  echo 'NEXT_STEP=IDENTIFY_NEAREST_EXISTING_SURFACE_THAT_ALREADY_POSSESSES_LIFECYCLE_INPUTS'
fi

echo 'AUTHORIZATION=ACTIVE'
echo 'NEW_AUTHORITY_ALLOWED=NO'
echo 'SYNTHETIC_LIFECYCLE_INPUTS_ALLOWED=NO'
echo 'IMPLEMENTATION_PERFORMED=NO'
echo 'COMMIT_PERFORMED=NO'
echo 'PUSH_PERFORMED=NO'

printf '\n=== SAFETY ===\n'
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git status --porcelain)"

printf 'LOCAL_HEAD=%s\n' "$(git rev-parse --short=9 HEAD)"
printf 'REMOTE_HEAD=%s\n' "$(git rev-parse --short=9 "origin/$BRANCH")"
printf 'DIVERGENCE='
git rev-list --left-right --count "HEAD...origin/$BRANCH"
