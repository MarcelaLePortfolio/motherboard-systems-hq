#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="579ae9c1e"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"

printf '\n=== EXACT PRODUCTION LIFECYCLE ENTRY POINT ===\n'
sed -n '1,180p' server/lifecycle/production-lifecycle-entry-point.ts

printf '\n=== EXACT PRODUCTION LIFECYCLE CONSUMER ===\n'
sed -n '1,260p' server/lifecycle/production-lifecycle-consumer.ts

printf '\n=== ALL NON-TEST IMPORTERS / CALLERS ON CURRENT BRANCH ===\n'
grep -RniE \
  --include='*.ts' --include='*.tsx' --include='*.mjs' \
  'consumeProductionLifecycleEntryPoint|invokeProductionLifecycleEntryPoint|production-lifecycle-entry-point' \
  server db routes client/src \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== GOVERNANCE LIFECYCLE ROUTE MOUNT / CALLER ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B20 -A60 \
  'createGovernanceLifecycleRouter|governance-lifecycle-route|/api/governance/lifecycle' \
  server routes \
  2>/dev/null || true

printf '\n=== LIVE FLOW NEIGHBORS ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B20 -A70 \
  'createGovernanceEnvelope|consumeProductionEnvelope|ENVELOPE_CREATED|department_handshake|effect_intent' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== CLASSIFICATION ===\n'

CALLERS="$(
  grep -RliE \
    --include='*.ts' --include='*.tsx' --include='*.mjs' \
    'consumeProductionLifecycleEntryPoint|invokeProductionLifecycleEntryPoint' \
    server db routes client/src \
    2>/dev/null \
    | grep -vE '\.test\.|\.spec\.|server/lifecycle/production-lifecycle-(entry-point|consumer)\.ts|server/routes/governance-lifecycle-route\.ts' \
    || true
)"

if [ -n "$CALLERS" ]; then
  echo 'LIVE_TRIGGER_BEYOND_LIFECYCLE_ROUTE=FOUND'
  printf '%s\n' "$CALLERS"
  echo 'NEXT_STEP=VERIFY_THIS_CALLER_IS_REACHED_FROM_LIVE_ENVELOPE_CREATION'
else
  echo 'LIVE_TRIGGER_BEYOND_LIFECYCLE_ROUTE=ABSENT'
  echo 'CONFIRMED_BOUNDARY=PRODUCTION_LIFECYCLE_EXISTS_BUT_IS_ONLY_EXPOSED_THROUGH_GOVERNANCE_LIFECYCLE_ROUTE'
  echo 'LIKELY_MISSING_SEAM=LIVE_ENVELOPE_FLOW_TO_GOVERNANCE_LIFECYCLE_ROUTE'
  echo 'NEXT_STEP=DEFINE_BOUNDED_HANDOFF_AND_REQUEST_IMPLEMENTATION_AUTHORIZATION'
fi

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
