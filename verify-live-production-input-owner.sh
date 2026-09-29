#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="00ded0984"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"
test -z "$(git diff --name-only)"

printf '\n=== CANDIDATE FULL INPUT OWNERS ===\n'
printf '%s\n' \
  'db/governance-lifecycle-integration.ts' \
  'server/lifecycle/production-lifecycle-consumer.ts' \
  'server/lifecycle/production-lifecycle-entry-point.ts' \
  'server/routes/governance-lifecycle-route.ts'

printf '\n=== PRODUCTION CALLERS OF CANDIDATES ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B20 -A70 \
  'completeGovernanceLifecycleAssignmentTransition|consumeProductionLifecycleEntryPoint|invokeProductionLifecycleEntryPoint|handleGovernanceLifecycleRouteRequest|createGovernanceLifecycleRouter' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== SERVER REGISTRATION ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B15 -A50 \
  'governance-lifecycle-route|createGovernanceLifecycleRouter|/api/governance/lifecycle' \
  server \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== INPUT ORIGIN AT ROUTE ===\n'
sed -n '65,235p' server/routes/governance-lifecycle-route.ts

printf '\n=== INPUT ORIGIN AT CONSUMER ===\n'
sed -n '56,220p' server/lifecycle/production-lifecycle-consumer.ts

printf '\n=== ENTRYPOINT BOUNDARY ===\n'
sed -n '1,190p' server/lifecycle/production-lifecycle-entry-point.ts

printf '\n=== CLASSIFICATION ===\n'
echo 'KNOWN=FULL_EXISTING_INPUT_OWNER_FOUND'
echo 'KNOWN=NO_SYNTHETIC_INPUTS_REQUIRED'
echo 'QUESTION=WHICH_FULL_INPUT_OWNER_IS_THE_LIVE_PRODUCTION_PROVENANCE_BOUNDARY'
echo 'TARGET=EXISTING_LIVE_OWNER_THAT_ALREADY_RECEIVES_HANDSHAKE_DEPARTMENTS_AND_PERSISTENCE'
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
