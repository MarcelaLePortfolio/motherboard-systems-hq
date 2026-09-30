#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="ccbde8c74"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

BEFORE_UNSTAGED="$(git diff --name-only)"

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

printf '\n=== DECISIVE RESULT ===\n'
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
  echo 'NEXT_STEP=IMPLEMENT_BOUNDED_LIVE_ENVELOPE_TO_LIFECYCLE_COMPOSITION'
else
  echo 'LIVE_PRODUCTION_PROVENANCE_CHAIN=NOT_VERIFIED'
  echo 'NEXT_STEP=STOP_AND_INSPECT_MISSING_LINK'
fi

echo 'NEW_AUTHORITY_ALLOWED=NO'
echo 'SYNTHETIC_INPUTS_ALLOWED=NO'
echo 'IMPLEMENTATION_PERFORMED=NO'

printf '\n=== SCOPED SAFETY ===\n'
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

AFTER_UNSTAGED="$(git diff --name-only)"
test "$BEFORE_UNSTAGED" = "$AFTER_UNSTAGED"
echo 'PREEXISTING_UNSTAGED_STATE=PRESERVED'

git add -- rerun-runtime-lifecycle-provenance-with-scoped-safety.sh
git commit -m "Rerun runtime lifecycle provenance with scoped safety"
git push origin "$BRANCH"
