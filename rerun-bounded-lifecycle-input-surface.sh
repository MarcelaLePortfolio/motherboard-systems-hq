#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="54d5abe4a"
TARGET="server/routes/governance-envelope-route.ts"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git status --porcelain)"

printf '\n=== ENVELOPE ROUTE INPUT MATCHES ===\n'
grep -nE \
  'department_handshake|available_departments|available_actors|ENVELOPE_CREATED' \
  "$TARGET" || true

printf '\n=== NON-TEST EXISTING INPUT SURFACES ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B12 -A40 \
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
  echo 'AUTHORIZED_NEXT_STEP=IMPLEMENT_BOUNDED_COMPOSITION_IN_ENVELOPE_FLOW'
else
  echo 'ENVELOPE_ROUTE_HAS_EXISTING_LIFECYCLE_INPUTS=NO'
  echo 'DIRECT_ENVELOPE_ROUTE_WIRING=REJECTED'
  echo 'AUTHORIZED_NEXT_STEP=IDENTIFY_EXISTING_COMPOSITION_SURFACE_WITH_REQUIRED_INPUTS'
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
