#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="e4c5ffb43"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"
test -z "$(git diff --name-only)"

printf '\n=== CURRENT CLASSIFICATION ===\n'
echo 'EXISTING_LIVE_SHARED_CALLER=ABSENT'
echo 'BOUNDED_HANDOFF=IMPLEMENTED'
echo 'NEXT_STEP=DEFINE_SMALLEST_NEW_COMPOSITION_SURFACE_WITHOUT_NEW_AUTHORITY'

printf '\n=== ENVELOPE RESULT SHAPE ===\n'
sed -n '1,285p' server/routes/governance-envelope-route.ts

printf '\n=== BOUNDED HANDOFF INPUT SHAPE ===\n'
sed -n '1,220p' server/lifecycle/production-envelope-lifecycle-handoff.ts

printf '\n=== LIFECYCLE ROUTE INPUT PROVENANCE ===\n'
sed -n '65,220p' server/routes/governance-lifecycle-route.ts

printf '\n=== EXISTING DEPARTMENT HANDSHAKE PRODUCERS ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B25 -A70 \
  'DepartmentAssignmentHandshake|department_handshake|ACKNOWLEDGED|CAPABILITY_CONFIRMED' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== EXISTING AVAILABLE DEPARTMENT SOURCES ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B20 -A60 \
  'available_departments|availableDepartments' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== EXISTING LIFECYCLE PERSISTENCE SOURCES ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B20 -A60 \
  'persist_lifecycle_transition|persistGovernanceEnvelopeLifecycleTransition|createDefaultLifecyclePersistence' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== MINIMAL SURFACE REQUIREMENTS ===\n'
echo 'NEW_SURFACE_MAY_COMPOSE_EXISTING_COMPONENTS=YES'
echo 'NEW_SURFACE_MAY_CREATE_AUTHORITY=NO'
echo 'NEW_SURFACE_MAY_SYNTHESIZE_DEPARTMENT_HANDSHAKE=NO'
echo 'NEW_SURFACE_MAY_SYNTHESIZE_AVAILABLE_DEPARTMENTS=NO'
echo 'NEW_SURFACE_MAY_BYPASS_LIFECYCLE_ENTRYPOINT=NO'
echo 'NEW_SURFACE_MAY_BYPASS_EXISTING_PERSISTENCE=NO'
echo 'ENVELOPE_ROUTE_SEMANTICS_MUST_REMAIN_BOUNDED=YES'
echo 'TARGET=POST_ENVELOPE_COMPOSITION_SURFACE_ACCEPTING_ALREADY_EXISTING_LIFECYCLE_INPUTS'

printf '\n=== CLASSIFICATION ===\n'
echo 'EXISTING_SHARED_CALLER=ABSENT'
echo 'ARCHITECTURAL_ACTION=NEW_MINIMAL_COMPOSITION_SURFACE_REQUIRED'
echo 'IMPLEMENTATION_SCOPE=COMPOSE_EXISTING_ENVELOPE_RESULT_WITH_EXISTING_LIFECYCLE_INPUTS_INTO_BOUNDED_HANDOFF'
echo 'NEW_AUTHORITY_REQUIRED=NO'
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
