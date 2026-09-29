#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="2e5e600aa"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"

printf '\n=== DELEGATION / LIFECYCLE FILES ===\n'
find server db routes -type f \( -name '*.ts' -o -name '*.mjs' \) 2>/dev/null \
  | grep -Ei 'delegation|lifecycle' | sort

printf '\n=== PRODUCTION DELEGATION COMPOSITION ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B20 -A100 \
  'production.*delegation|consumeProduction.*Delegation|invokeProduction.*Delegation|createGovernanceDelegation' \
  server db routes 2>/dev/null || true

printf '\n=== EXISTING LIFECYCLE TRANSITION ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B25 -A120 \
  'transition.*lifecycle|lifecycle.*transition|ENVELOPE_CREATED.*ASSIGNED|ASSIGNED.*ENVELOPE_CREATED' \
  server db routes 2>/dev/null || true

printf '\n=== CROSS-CALLS ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  'lifecycle|transition' \
  server/delegation server/routes 2>/dev/null || true

printf '\n=== CLASSIFICATION ===\n'
echo 'KNOWN_VALIDATION_LIFECYCLE_AUTHORITY=FALSE'
echo 'KNOWN_LIVE_ENVELOPE_STATE=ENVELOPE_CREATED'
echo 'QUESTION=DOES_PRODUCTION_DELEGATION_COMPOSE_EXISTING_LIFECYCLE_TRANSITION'
echo 'TARGET=EXACT_PRODUCTION_COMPOSITION_SEAM'
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
