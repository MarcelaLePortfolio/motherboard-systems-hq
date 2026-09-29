#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="ead0608fe"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"
test -z "$(git diff --name-only)"

printf '\n=== DIRECT NON-TEST LIFECYCLE CALLERS ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  'consumeProductionLifecycleEntryPoint\(|invokeProductionLifecycleEntryPoint\(|handleGovernanceLifecycleRouteRequest\(|createGovernanceLifecycleRouter\(' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== LIVE SERVER ROUTE REGISTRATION ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B15 -A45 \
  'createGovernanceLifecycleRouter|governanceLifecycleRouter|governance-lifecycle-route|/api/governance/lifecycle' \
  server \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== CONSUMER CALL CHAIN ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B15 -A50 \
  'consumeProductionLifecycle|invokeProductionLifecycleEntryPoint|persistGovernanceEnvelopeLifecycleTransition' \
  server db \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== CLASSIFICATION ===\n'
echo 'KNOWN=FULL_EXISTING_INPUT_OWNER_FOUND'
echo 'KNOWN=NO_SYNTHETIC_INPUTS_REQUIRED'
echo 'QUESTION=WHICH_OWNER_IS_ACTUALLY_REACHED_BY_LIVE_SERVER_RUNTIME'
echo 'TARGET=LIVE_ROUTE_TO_CONSUMER_TO_ENTRYPOINT_PROVENANCE_CHAIN'
echo 'NEW_AUTHORITY_ALLOWED=NO'
echo 'SYNTHETIC_INPUTS_ALLOWED=NO'
echo 'IMPLEMENTATION_PERFORMED=NO'

printf '\n=== SAFETY ===\n'
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"
test -z "$(git diff --name-only)"

printf 'LOCAL_HEAD=%s\n' "$(git rev-parse --short=9 HEAD)"
printf 'REMOTE_HEAD=%s\n' "$(git rev-parse --short=9 "origin/$BRANCH")"
printf 'DIVERGENCE='
git rev-list --left-right --count "HEAD...origin/$BRANCH"
