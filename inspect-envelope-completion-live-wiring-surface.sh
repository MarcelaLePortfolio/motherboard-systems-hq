#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="3c9347b37"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

printf '\n=== ENVELOPE COMPLETION SURFACE ===\n'
sed -n '130,285p' server/routes/governance-envelope-route.ts

printf '\n=== PRODUCTION ENVELOPE ENTRYPOINT CALLERS ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B20 -A70 \
  'consumeProductionEnvelopeEntryPoint|consumeProductionEnvelope' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== EXISTING LIFECYCLE INPUT OWNERS ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B20 -A60 \
  'available_departments|available_actors|department_handshake|persist_lifecycle_transition' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== BOUNDED HANDOFF CONTRACT ===\n'
sed -n '1,240p' \
  server/lifecycle/production-envelope-lifecycle-handoff.ts

printf '\n=== CLASSIFICATION ===\n'
echo 'KNOWN=BOUNDED_HANDOFF_IMPLEMENTED'
echo 'KNOWN=LIVE_RUNTIME_HANDOFF_CALLER_ABSENT'
echo 'QUESTION=WHICH_EXISTING_POST_ENVELOPE_SURFACE_ALREADY_OWNS_REQUIRED_LIFECYCLE_INPUTS'
echo 'TARGET=EXACT_LIVE_COMPOSITION_POINT'
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
