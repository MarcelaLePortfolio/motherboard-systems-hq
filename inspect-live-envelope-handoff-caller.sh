#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="f7e7dfe11"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git status --porcelain)"

printf '\n=== ENVELOPE ROUTE / CONSUMER CALLERS ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B20 -A70 \
  'governance-envelope-route|consumeProductionEnvelope|production-envelope|createGovernanceEnvelope\(' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== LIFECYCLE ROUTE / CONSUMER CALLERS ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B20 -A70 \
  'governance-lifecycle-route|consumeProductionLifecycleEntryPoint|production-lifecycle-consumer' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== SHARED PRODUCTION COMPOSITION SURFACES ===\n'
for f in $(grep -RlE \
  --include='*.ts' --include='*.mjs' \
  'createGovernanceEnvelope|consumeProductionEnvelope|consumeProductionLifecycleEntryPoint|department_handshake|available_departments|available_actors' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' \
  | sort -u); do
  printf '\n--- %s ---\n' "$f"
  grep -nE \
    'createGovernanceEnvelope|consumeProductionEnvelope|consumeProductionLifecycleEntryPoint|department_handshake|available_departments|available_actors|ENVELOPE_CREATED' \
    "$f" || true
done

printf '\n=== CLASSIFICATION ===\n'
echo 'KNOWN=ENVELOPE_ROUTE_DOES_NOT_OWN_LIFECYCLE_INPUTS'
echo 'KNOWN=LIFECYCLE_SURFACE_OWNS_REQUIRED_INPUT_CONTRACT'
echo 'QUESTION=WHICH_EXISTING_PRODUCTION_CALLER_SEES_BOTH_ENVELOPE_COMPLETION_AND_LIFECYCLE_INPUTS'
echo 'TARGET=EXACT_SHARED_COMPOSITION_SURFACE'
echo 'NEW_AUTHORITY_REQUIRED=NO'
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
