#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="22d13e424"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"
test -z "$(git diff --name-only)"

printf '\n=== ENVELOPE COMPLETION SURFACES ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B20 -A80 \
  'createGovernanceEnvelope|consumeProductionEnvelope|ENVELOPE_CREATED' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== AUTHORITY-BEARING LIFECYCLE SURFACES ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B15 -A60 \
  'available_departments|department_handshake|persist_lifecycle_transition' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== CROSS-SURFACE CALL GRAPH ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B20 -A80 \
  'handleGovernanceEnvelopeRouteRequest|createGovernanceEnvelope|consumeProductionEnvelope|handleGovernanceLifecycleRouteRequest|consumeProductionLifecycleEntryPoint|handoffProductionEnvelopeToLifecycle' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== ROUTE REGISTRATION / PRODUCTION CALLERS ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B15 -A50 \
  'governance-envelope-route|governance-lifecycle-route|handleGovernanceEnvelopeRouteRequest|handleGovernanceLifecycleRouteRequest' \
  server routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== CLASSIFICATION ===\n'
echo 'KNOWN=BOUNDED_HANDOFF_IMPLEMENTED'
echo 'KNOWN=LIVE_RUNTIME_HANDOFF_CALLER_ABSENT'
echo 'KNOWN=LIFECYCLE_ROUTE_OWNS_REQUIRED_INPUT_CONTRACT'
echo 'QUESTION=WHICH_EXISTING_LIVE_POST_ENVELOPE_CALLER_ALREADY_OWNS_REQUIRED_LIFECYCLE_INPUTS_AND_PERSISTENCE'
echo 'TARGET=SMALLEST_EXISTING_AUTHORITY_BEARING_COMPOSITION_SURFACE'
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
