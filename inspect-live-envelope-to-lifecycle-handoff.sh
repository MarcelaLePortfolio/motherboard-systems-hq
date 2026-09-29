#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="b9dd56915"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git status --porcelain)"

printf '\n=== LIVE ENVELOPE CREATION CALLERS ===\n'
grep -RniE \
  --include='*.ts' --include='*.tsx' --include='*.mjs' \
  -B25 -A80 \
  'createGovernanceEnvelope\(|consumeProductionEnvelope|production-envelope|governance-envelope-creation' \
  server db routes client/src \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== LIFECYCLE ROUTE ===\n'
sed -n '1,260p' server/routes/governance-lifecycle-route.ts 2>/dev/null || true

printf '\n=== PRODUCTION LIFECYCLE INPUT CONTRACT ===\n'
sed -n '1,260p' server/lifecycle/production-lifecycle-entry-point.ts
sed -n '1,320p' server/lifecycle/production-lifecycle-consumer.ts

printf '\n=== ASSIGNMENT INPUT SOURCES ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B20 -A70 \
  'available_departments|available_actors|department_handshake|DepartmentAssignmentHandshake' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== ENVELOPE CREATION RETURN / HANDOFF SURFACES ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B30 -A100 \
  'ENVELOPE_CREATED|lifecycle_state.*ENVELOPE_CREATED|createGovernanceEnvelope\(' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== CLASSIFICATION ===\n'
echo 'KNOWN=PRODUCTION_LIFECYCLE_ENTRY_POINT_EXISTS'
echo 'KNOWN=ENVELOPE_CREATED_TO_ASSIGNED_TRANSITION_EXISTS'
echo 'KNOWN=LIVE_TRIGGER_BEYOND_LIFECYCLE_ROUTE_ABSENT'
echo 'QUESTION=WHAT_EXACT_LIVE_ENVELOPE_CREATION_SURFACE_CAN_HAND_OFF_TO_EXISTING_LIFECYCLE_ENTRY_POINT'
echo 'TARGET=SMALLEST_BOUNDED_HANDOFF_WITH_EXISTING_AUTHORITY_ONLY'
echo 'NEW_AUTHORITY_REQUIRED=NO'
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
