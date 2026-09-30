#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="aa06a72f6"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

BEFORE_UNSTAGED="$(git diff --name-only)"

printf '\n=== EXISTING BOUNDED HANDOFF ===\n'
sed -n '1,240p' server/lifecycle/production-envelope-lifecycle-handoff.ts

printf '\n=== HANDOFF TEST CONTRACT ===\n'
sed -n '1,320p' server/lifecycle/production-envelope-lifecycle-handoff.test.ts

printf '\n=== ENVELOPE ROUTE RESULT CONTRACT ===\n'
sed -n '1,320p' server/routes/governance-envelope-route.ts

printf '\n=== LIFECYCLE ROUTE INPUT CONTRACT ===\n'
sed -n '1,280p' server/routes/governance-lifecycle-route.ts

printf '\n=== PRODUCTION CONSUMER INPUT CONTRACT ===\n'
sed -n '1,240p' server/lifecycle/production-lifecycle-consumer.ts

printf '\n=== LIVE ROUTE REGISTRATION ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B20 -A60 \
  'createGovernanceEnvelopeRouter|createGovernanceLifecycleRouter|governance-envelope-route|governance-lifecycle-route' \
  server \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== AUTHORIZED IMPLEMENTATION CLASSIFICATION ===\n'
echo 'AUTHORIZATION=ACTIVE'
echo 'TARGET=MINIMAL_POST_ENVELOPE_LIFECYCLE_COMPOSITION_SURFACE'
echo 'REUSE_EXISTING_BOUNDED_HANDOFF=YES'
echo 'REUSE_EXISTING_LIFECYCLE_INPUTS=YES'
echo 'REUSE_EXISTING_PERSISTENCE=YES'
echo 'NEW_AUTHORITY_ALLOWED=NO'
echo 'SYNTHETIC_INPUTS_ALLOWED=NO'
echo 'ENVELOPE_ROUTE_AUTHORITY_EXPANSION_ALLOWED=NO'
echo 'IMPLEMENTATION_PERFORMED=NO'
echo 'NEXT_STEP=IMPLEMENT_FROM_VERIFIED_EXISTING_CONTRACTS'

printf '\n=== SCOPED SAFETY ===\n'
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

AFTER_UNSTAGED="$(git diff --name-only)"
test "$BEFORE_UNSTAGED" = "$AFTER_UNSTAGED"
echo 'PREEXISTING_UNSTAGED_STATE=PRESERVED'

git add -- inspect-authorized-post-envelope-composition-contract.sh
git commit -m "Inspect authorized post-envelope composition contract"
git push origin "$BRANCH"
