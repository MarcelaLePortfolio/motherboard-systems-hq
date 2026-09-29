#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="027743a7c"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"
test -z "$(git diff --name-only)"

ROUTE_REGISTERED=0
ROUTE_TO_CONSUMER=0
CONSUMER_TO_ENTRYPOINT=0
PERSISTENCE_PRESENT=0

grep -RqE \
  --include='*.ts' --include='*.mjs' \
  'createGovernanceLifecycleRouter|governanceLifecycleRouter|/api/governance/lifecycle' \
  server 2>/dev/null && ROUTE_REGISTERED=1 || true

grep -qE \
  'consumeProductionLifecycleEntryPoint\(' \
  server/routes/governance-lifecycle-route.ts \
  2>/dev/null && ROUTE_TO_CONSUMER=1 || true

grep -qE \
  'invokeProductionLifecycleEntryPoint\(' \
  server/lifecycle/production-lifecycle-consumer.ts \
  2>/dev/null && CONSUMER_TO_ENTRYPOINT=1 || true

grep -qE \
  'persistGovernanceEnvelopeLifecycleTransition\(' \
  server/lifecycle/production-lifecycle-consumer.ts \
  2>/dev/null && PERSISTENCE_PRESENT=1 || true

printf '\n=== LIVE RUNTIME LIFECYCLE PROVENANCE RESULT ===\n'
echo "LIVE_ROUTE_REGISTERED=$ROUTE_REGISTERED"
echo "ROUTE_TO_CONSUMER=$ROUTE_TO_CONSUMER"
echo "CONSUMER_TO_ENTRYPOINT=$CONSUMER_TO_ENTRYPOINT"
echo "EXISTING_PERSISTENCE_BOUNDARY=$PERSISTENCE_PRESENT"

printf '\n=== CLASSIFICATION ===\n'

if [ "$ROUTE_REGISTERED" -eq 1 ] &&
   [ "$ROUTE_TO_CONSUMER" -eq 1 ] &&
   [ "$CONSUMER_TO_ENTRYPOINT" -eq 1 ] &&
   [ "$PERSISTENCE_PRESENT" -eq 1 ]; then
  echo 'LIVE_PRODUCTION_PROVENANCE_CHAIN=VERIFIED'
  echo 'IMPLEMENTATION_BOUNDARY=NEW_MINIMAL_POST_ENVELOPE_COMPOSITION_SURFACE'
  echo 'COMPOSITION_TARGET=EXISTING_GOVERNANCE_LIFECYCLE_ROUTE_CONSUMER_ENTRYPOINT_CHAIN'
  echo 'NEXT_STEP=IMPLEMENT_BOUNDED_LIVE_ENVELOPE_TO_LIFECYCLE_COMPOSITION'
else
  echo 'LIVE_PRODUCTION_PROVENANCE_CHAIN=NOT_VERIFIED'
  echo 'NEXT_STEP=STOP_AND_INSPECT_MISSING_LINK'
fi

echo 'NEW_AUTHORITY_ALLOWED=NO'
echo 'SYNTHETIC_INPUTS_ALLOWED=NO'
echo 'ENVELOPE_ROUTE_SEMANTICS_MUST_REMAIN_UNCHANGED=YES'
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
